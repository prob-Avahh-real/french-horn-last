import 'dart:ffi';

/// Audio format constants
const kAudioFormatLinearPCM = 0x6C70636D;
const kAudioFormatFlagIsFloat = 1;
const kAudioFormatFlagIsPacked = 8;

// ── Structs ──

final class AudioStreamBasicDescription extends Struct {
  @Double() external double mSampleRate;
  @Uint32() external int mFormatID;
  @Uint32() external int mFormatFlags;
  @Uint32() external int mBytesPerPacket;
  @Uint32() external int mFramesPerPacket;
  @Uint32() external int mBytesPerFrame;
  @Uint32() external int mChannelsPerFrame;
  @Uint32() external int mBitsPerChannel;
  @Uint32() external int mReserved;
}

final class AudioQueueBuffer extends Struct {
  @Uint32() external int mAudioDataBytesCapacity;
  external Pointer<Uint8> mAudioData;
  @Uint32() external int mAudioDataByteSize;
  external Pointer<Void> mUserData;
}

// ── Callback ──

typedef AudioQueueOutputCallbackC = Void Function(
  Pointer<Void>, Pointer<Void>, Pointer<AudioQueueBuffer>);
typedef AudioQueueOutputCallbackDart = void Function(
  Pointer<Void>, Pointer<Void>, Pointer<AudioQueueBuffer>);

// ── Function typedefs ──

typedef AQNewOutputC = Int32 Function(Pointer<AudioStreamBasicDescription>,
    Pointer<NativeFunction<AudioQueueOutputCallbackC>>, Pointer<Void>,
    Pointer<Void>, Pointer<Void>, Uint32, Pointer<Pointer<Void>>);
typedef AQNewOutputDart = int Function(Pointer<AudioStreamBasicDescription>,
    Pointer<NativeFunction<AudioQueueOutputCallbackC>>, Pointer<Void>,
    Pointer<Void>, Pointer<Void>, int, Pointer<Pointer<Void>>);

typedef AQAllocBufC = Int32 Function(Pointer<Void>, Uint32, Pointer<Pointer<AudioQueueBuffer>>);
typedef AQAllocBufDart = int Function(Pointer<Void>, int, Pointer<Pointer<AudioQueueBuffer>>);

typedef AQEnqueueC = Int32 Function(Pointer<Void>, Pointer<AudioQueueBuffer>, Uint32, Pointer<Void>);
typedef AQEnqueueDart = int Function(Pointer<Void>, Pointer<AudioQueueBuffer>, int, Pointer<Void>);

typedef AQStartC = Int32 Function(Pointer<Void>, Pointer<Void>);
typedef AQStartDart = int Function(Pointer<Void>, Pointer<Void>);

typedef AQStopC = Int32 Function(Pointer<Void>, Uint8);
typedef AQStopDart = int Function(Pointer<Void>, int);

typedef AQDisposeC = Int32 Function(Pointer<Void>, Uint8);
typedef AQDisposeDart = int Function(Pointer<Void>, int);
