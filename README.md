# Verilog-final-project
Frequency analysis system in verilog
You need to design a system with Finite Impulse Response filter (FIR filter),a Fast Fourier Transform (FFT) circuit and a analysis circuit.
This system can filter out the noise with FIR filter and then transform the signals from time domain into frequency domain with FFT circuit.

BLOCK overview
![image](https://user-images.githubusercontent.com/74757651/145251016-3b2d524e-210d-40c7-83a8-cc759d8c5621.png)

![image](https://user-images.githubusercontent.com/74757651/145252061-dff2880b-c66f-4ffb-8d9a-142547b32aa4.png)




After the input signal is filtered and is ready to output, pull up the fir_valid signal. And use fir_d signal to transmit one data in each cycle. The filtered signal will then be processed by FFT, and the frequency domain signal can be obtained. (Take figure 4 as example.) Pull up fft_valid signal and use fft_d signal to transmit one
Fig. 2 – Time domain signals from the host.
Fig. 3 – Signals which passed the FIR filter.
set of data (fft_d0 ~ fft_d15) to the Analysis circuit. When the Analysis circuit complete calculation, pull up done signal and output the main frequency band by freq signal. Among the signals fft_d0 ~ fft_d15, fft_d0 represents the frequency band 0, fft_d1 represents the frequency band 1, and so on.

![image](https://user-images.githubusercontent.com/74757651/145252014-cb4a80d8-cd4f-4ed4-b4d5-878040f4e65c.png)





