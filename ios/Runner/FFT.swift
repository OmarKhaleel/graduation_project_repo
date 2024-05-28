import Accelerate

class FFT {
    private var log2n: UInt
    private var fftSetup: FFTSetup
    private var window: [Float]
    private var windowSize: vDSP_Length
    private var windowSizeInt: Int
    private var halfWindowSize: Int
    private var complexBuffer: DSPSplitComplex
    private var realp: [Float]
    private var imagp: [Float]

    init(bufferSize: Int) {
        log2n = UInt(round(log2(Float(bufferSize))))
        fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        windowSize = vDSP_Length(bufferSize)
        windowSizeInt = bufferSize
        halfWindowSize = bufferSize / 2

        window = [Float](repeating: 0, count: windowSizeInt)
        vDSP_hann_window(&window, windowSize, Int32(vDSP_HANN_NORM))

        realp = [Float](repeating: 0, count: halfWindowSize)
        imagp = [Float](repeating: 0, count: halfWindowSize)
        complexBuffer = DSPSplitComplex(realp: &realp, imagp: &imagp)
    }

    func calculate(samples: [Float]) {
        var windowedSamples = [Float](repeating: 0, count: windowSizeInt)
        vDSP_vmul(samples, 1, window, 1, &windowedSamples, 1, windowSize)

        var complexBuffer = DSPSplitComplex(realp: &realp, imagp: &imagp)
        windowedSamples.withUnsafeBufferPointer { ptr in
            ptr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: windowSizeInt) {
                vDSP_ctoz($0, 2, &complexBuffer, 1, vDSP_Length(halfWindowSize))
            }
        }

        vDSP_fft_zrip(fftSetup, &complexBuffer, 1, log2n, Int32(FFT_FORWARD))

        var magnitudes = [Float](repeating: 0.0, count: halfWindowSize)
        vDSP_zvmags(&complexBuffer, 1, &magnitudes, 1, vDSP_Length(halfWindowSize))

        var normalizedMagnitudes = [Float](repeating: 0.0, count: halfWindowSize)
        vDSP_vsmul(sqrt(magnitudes), 1, [2.0 / Float(windowSizeInt)], &normalizedMagnitudes, 1, vDSP_Length(halfWindowSize))

        self.realp = normalizedMagnitudes
    }

    var maxFrequency: Float {
        let maxIndex = realp.indices.max(by: { realp[$0] < realp[$1] })!
        let maxFrequency = Float(maxIndex) * 44100 / Float(windowSizeInt)
        return maxFrequency
    }

    func spectrogram() -> [Float] {
        return realp
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }
}
