import 'dart:typed_data';

class MidiNote {
  final int noteNumber;
  final double startTime;
  final double duration;
  const MidiNote({required this.noteNumber, required this.startTime, required this.duration});
  double get endTime => startTime + duration;
}

class MidiTrack {
  final String songId;
  final double bpm;
  final List<MidiNote> notes;
  final double totalDuration;
  const MidiTrack({required this.songId, required this.bpm, required this.notes, required this.totalDuration});

  List<MidiNote> activeNotes(double currentTime, {double windowMs = 500}) {
    final w = windowMs / 1000;
    return notes.where((n) => currentTime >= n.startTime - w && currentTime <= n.endTime + w).toList();
  }

  MidiNote? upcomingNote(double currentTime) {
    MidiNote? closest;
    for (final n in notes) {
      if (n.startTime > currentTime && (closest == null || n.startTime < closest.startTime)) {
        closest = n;
      }
    }
    return closest;
  }

  double targetPitchAt(double currentTime) {
    for (final n in notes) {
      if (currentTime >= n.startTime && currentTime <= n.endTime) return n.noteNumber.toDouble();
    }
    MidiNote? next;
    for (final n in notes) {
      if (n.startTime > currentTime) { next = n; break; }
    }
    if (next != null) {
      MidiNote? prev;
      for (final n in notes.reversed) {
        if (n.endTime < currentTime) { prev = n; break; }
      }
      return (prev?.noteNumber ?? next.noteNumber).toDouble();
    }
    return 69;
  }
}

// ── MIDI Binary Parser ──

class MidiParser {
  static MidiTrack parse(String songId, List<int> bytes) {
    final data = Uint8List.fromList(bytes);
    var off = 0;

    if (!_expect(data, off, 'MThd')) throw FormatException('Bad MIDI header');
    off += 4;
    final hdrLen = _u32(data, off); off += 4;
    off += 2; // format
    final ntrks = _u16(data, off); off += 2;
    final division = _i16(data, off); off += 2;
    if (division <= 0) throw FormatException('SMPTE not supported');
    final tpq = division;
    off += hdrLen - 6;

    final allTracks = <_Trk>[];
    for (var t = 0; t < ntrks; t++) {
      if (!_expect(data, off, 'MTrk')) throw FormatException('Missing MTrk $t');
      off += 4;
      final trkLen = _u32(data, off); off += 4;
      final end = off + trkLen;
      final rawNotes = <_Raw>[];
      final tempos = <_Tmp>[];
      var trackCh = 0;
      var running = 0;
      var absTick = 0;

      while (off < end) {
        final d = _vlq(data, off); off = d.off; absTick += d.val;
        var status = data[off];
        if ((status & 0x80) == 0) { status = running; } else { running = status; off++; }
        final ev = status & 0xF0;
        final ch = status & 0x0F;
        trackCh = ch;

        switch (ev) {
          case 0x80:
            final n = data[off++]; data[off++]; _close(rawNotes, n, absTick);
            break;
          case 0x90:
            final n = data[off++]; final v = data[off++];
            if (v == 0) { _close(rawNotes, n, absTick); } else {
              rawNotes.add(_Raw(note: n, tick: absTick, vel: v, ch: ch));
            }
            break;
          case 0xA0: off += 2; break;
          case 0xB0: off += 2; break;
          case 0xC0: off++; break;
          case 0xD0: off++; break;
          case 0xE0: off += 2; break;
          case 0xF0:
            if (status == 0xFF) {
              final mt = data[off++];
              final ml = _vlq(data, off); off = ml.off;
              final md = data.sublist(off, off + ml.val); off += ml.val;
              if (mt == 0x2F) { off = end; }
              else if (mt == 0x51 && ml.val == 3) {
                tempos.add(_Tmp(tick: absTick, mpqn: (md[0] << 16) | (md[1] << 8) | md[2]));
              }
            } else if (status == 0xF0 || status == 0xF7) {
              final sl = _vlq(data, off); off = sl.off + sl.val;
            }
            break;
        }
      }

      final maxT = absTick;
      for (final r in rawNotes.where((r) => r.dur == null)) { r.dur = maxT - r.tick; }

      allTracks.add(_Trk(
        notes: rawNotes.where((r) => r.dur != null).toList(),
        tempos: tempos,
        score: _melScore(rawNotes, trackCh),
      ));
    }

    final allTmp = <_Tmp>[];
    for (final t in allTracks) { allTmp.addAll(t.tempos); }
    allTmp.sort((a, b) => a.tick.compareTo(b.tick));
    if (allTmp.isEmpty || allTmp.first.tick != 0) { allTmp.insert(0, const _Tmp(tick: 0, mpqn: 500000)); }

    allTracks.sort((a, b) => b.score.compareTo(a.score));
    final mel = allTracks.first;
    mel.notes.sort((a, b) => a.tick.compareTo(b.tick));

    final out = <MidiNote>[];
    var ti = 0;
    var lt = 0;
    var ls = 0.0;

    for (final r in mel.notes) {
      while (ti + 1 < allTmp.length && allTmp[ti + 1].tick <= r.tick) {
        ls += _t2s(allTmp[ti + 1].tick - lt, tpq, allTmp[ti].mpqn);
        lt = allTmp[ti + 1].tick;
        ti++;
      }
      final st = ls + _t2s(r.tick - lt, tpq, allTmp[ti].mpqn);
      final dur = _t2s(r.dur!, tpq, allTmp[ti].mpqn).clamp(0.05, 5.0);
      out.add(MidiNote(noteNumber: r.note, startTime: st, duration: dur));
    }

    final avgMpqn = allTmp.fold<int>(0, (s, t) => s + t.mpqn) ~/ allTmp.length;
    final bpm = 60000000.0 / avgMpqn;

    var maxTick = 0;
    for (final r in mel.notes) { final e = r.tick + (r.dur ?? 0); if (e > maxTick) maxTick = e; }
    ti = 0; lt = 0; ls = 0;
    while (ti + 1 < allTmp.length && allTmp[ti + 1].tick <= maxTick) {
      ls += _t2s(allTmp[ti + 1].tick - lt, tpq, allTmp[ti].mpqn);
      lt = allTmp[ti + 1].tick;
      ti++;
    }
    final durTotal = ls + _t2s(maxTick - lt, tpq, allTmp[ti].mpqn);

    return MidiTrack(songId: songId, bpm: bpm, notes: out, totalDuration: durTotal);
  }

  static MidiTrack generateTestTrack(String songId, double bpm) {
    final notes = <MidiNote>[];
    const nl = 0.5;
    const scale = [0, 2, 4, 5, 7, 9, 11, 12];
    for (var i = 0; i < scale.length; i++) {
      notes.add(MidiNote(noteNumber: 60 + scale[i], startTime: i * nl, duration: nl * 0.8));
    }
    return MidiTrack(songId: songId, bpm: bpm, notes: notes, totalDuration: scale.length * nl);
  }
}

// ── internals ──

class _Raw { int note; int tick; int vel; int ch; int? dur; _Raw({required this.note, required this.tick, required this.vel, required this.ch}); }
class _Tmp { final int tick; final int mpqn; const _Tmp({required this.tick, required this.mpqn}); }
class _Trk { final List<_Raw> notes; final List<_Tmp> tempos; final double score; const _Trk({required this.notes, required this.tempos, required this.score}); }
class _Vlq { final int val; final int off; const _Vlq(this.val, this.off); }

double _melScore(List<_Raw> notes, int ch) {
  if (notes.isEmpty || ch == 9) return -1;
  final ns = notes.where((n) => n.dur != null).toList();
  if (ns.isEmpty) return 0;
  final avg = ns.fold<int>(0, (s, n) => s + n.note) ~/ ns.length;
  return avg * ns.length.toDouble();
}

void _close(List<_Raw> notes, int note, int endTick) {
  for (var i = notes.length - 1; i >= 0; i--) {
    if (notes[i].note == note && notes[i].dur == null) { notes[i].dur = endTick - notes[i].tick; return; }
  }
}

double _t2s(int ticks, int tpq, int mpqn) => (ticks / tpq) * (mpqn / 1000000.0);

bool _expect(Uint8List data, int off, String magic) {
  if (off + magic.length > data.length) return false;
  for (var i = 0; i < magic.length; i++) { if (data[off + i] != magic.codeUnitAt(i)) return false; }
  return true;
}

int _u32(Uint8List d, int o) => (d[o] << 24) | (d[o + 1] << 16) | (d[o + 2] << 8) | d[o + 3];
int _u16(Uint8List d, int o) => (d[o] << 8) | d[o + 1];
int _i16(Uint8List d, int o) { final v = (d[o] << 8) | d[o + 1]; return v > 0x7FFF ? v - 0x10000 : v; }

_Vlq _vlq(Uint8List d, int o) {
  var v = 0;
  for (var i = 0; i < 4; i++) { v = (v << 7) | (d[o + i] & 0x7F); if ((d[o + i] & 0x80) == 0) return _Vlq(v, o + i + 1); }
  return _Vlq(v, o + 4);
}
