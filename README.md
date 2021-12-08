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



Timing Diagram
The timing specification of this design contains four parts: The system timing specification, the input signal timing specification, the FIR output timing specification, and the FFT output timing specification.

The timing diagram in figure 5 shows the system timing specification. 
After the system is reset, the serial input signals pass FIR filter and output by fir_d serially. Every sixteen output signals from FIR filter will be parallel input to the FFT circuit. The FFT circuit will output the processed signal parallel with signals fft_d0 ~ fft_d15. 
The Analysis circuit takes these signals and processes them to find the main frequency band. Finally, the main frequency band is output with freq signal. The done signal has to be pulled up at the same time to inform the host that the set of sixteen signals have been processed. 
The fir_valid, fft_valid, and done signals all maintain as high for 1 cycle for each valid output data. Besides, there is no overlap between any two sets of valid output of FIR filter. For example, the first set of FFT parallel input is constructed with fir_d(0) ~ fir_d(15), and the second set of FFT parallel input will be constructed with fir_d(16) ~ fir_d(31), and so on. 
The host will input 1024 data to the system, so there will be 64 calculation results output by the system.

![image](https://user-images.githubusercontent.com/74757651/145252240-9edf06c6-05e1-4ae1-a0e8-056c028fe0bd.png)


Functionality of FIR filter

The FIR filter in the system is a low pass filter with 32 coefficients, and it is responsible for filtering out the high frequency noise. The coefficients of the filter are fixed, and they are shown in table 2. (They are also stored in the file “FIR_coefficient.dat”.) The first valid output will be calculated after the thirty-second data is input to the FIR filter. Equation 1 shows the calculation process of FIR filter. Figure 9 shows its hardware architecture, and figure 10 shows the format of input data and output fir_d.

![image](https://user-images.githubusercontent.com/74757651/145252455-6b92111c-5805-4e7c-8a95-088141447a2c.png)
![image](https://user-images.githubusercontent.com/74757651/145252942-e79b8465-fcde-4949-b3f2-6c1263948865.png)

Functionality of FFT circuit
In this system, you are requested to complete a sixteen-point fast Fourier transform. 
Its hardware architecture is shown in below. The FFT circuit is used to transform the time domain signals into frequency domain signals for following analysis.

Below is an example of the FFT calculation process. The minus sign in the path of fft_b represents the calculation of subtract Y from X, and Wn is the FFT coefficient. The FFT coefficient contains real part (Wn_real) and imaginary part (Wn_imag). To obtain the results, the complex number operations have to be calculated. Figure 13 shows the result of fft_b after the multiplication.

![image](https://user-images.githubusercontent.com/74757651/145252768-86e149c7-3cdc-4ee1-8661-0a146af8ea3b.png)
![image](https://user-images.githubusercontent.com/74757651/145252796-593e7111-973c-4a29-b756-482ba1c61ae7.png)


![image](https://user-images.githubusercontent.com/74757651/145252619-064a4195-16c2-4b19-b6d9-c99967c40b4d.png)


