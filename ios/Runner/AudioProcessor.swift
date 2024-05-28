import Foundation
import Accelerate

class AudioProcessor {
    func performFFT(_ window: [Double]) -> [Double] {
        var real = window
        var imaginary = [Double](repeating: 0.0, count: window.count)
        var splitComplex = DSPDoubleSplitComplex(realp: &real, imagp: &imaginary)

        let length = vDSP_Length(vDSP_Length(floor(log2(Float(window.count)))))
        let fftSetup = vDSP_create_fftsetupD(length, FFTRadix(kFFTRadix2))

        vDSP_fft_zipD(fftSetup!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))

        var magnitudes = [Double](repeating: 0.0, count: window.count / 2)
        vDSP_zvmagsD(&splitComplex, 1, &magnitudes, 1, vDSP_Length(magnitudes.count))

        vDSP_destroy_fftsetupD(fftSetup)
        return magnitudes
    }
}
