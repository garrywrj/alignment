%--------查看设备名称-----------
info = audiodevinfo;
name = info.input(2).Name;
Micrname = sprintf('%s',name);
clear all
fs = 16000;
audioFrameLength = 1024;    
nChan = 2;
ith = 1;
filename1 = '200 Hz Sine Wave Sound Frequency Tone_R.wav';
%filename2 = 'D:/优本项目/Recordingdata/denoise-record/allnoise/99518-soundstew-file0274-98.wav';
[freader1,fs1]  = audioread(filename1);

Pw = [0.01 0.25 0.5 1 0.5 0.25 0.01];
Sw = Pw*0.25;
Shx = [-0.7034 1.4126 -0.2904 -1.3374 -0.5128 -0.0812 0.3510 -0.5722 1.2015 0.8906 -0.3804 0.2035 2.0135 -1.4928 0.3311 -0.4395];
Shw = [0.0025 0.0625 0.1250 0.2500 0.1250 0.0625 0.0025 1.2219e-17 4.8071e-18 1.6517e-17 2.6748e-17 6.8581e-18 1.7364e-17 -8.2828e-17 -6.3358e-18 9.1473e-17];

mu_lms = 0.2;


f1              = dsp.SignalSource(freader1,'SamplesPerFrame',1024);

%freader1  = dsp.AudioFileReader(filename1,'SamplesPerFrame',1024);

fplayer1  = dsp.AudioPlayer('DeviceName','7-8 (OCTA-CAPTURE)','SampleRate',fs1);
fplayer2  = dsp.AudioPlayer('DeviceName','3-4 (OCTA-CAPTURE)','SampleRate',fs1);


H = dsp.FilteredXLMSFilter('StepSize',mu_lms,...
                           'Length',16,...
                           'SecondaryPathCoefficients',Sw,...
                           'SecondaryPathEstimate',Shw);
hafw1 = dsp.AudioFileWriter(...
            'test.wav',...
            'FileFormat','wav',...
            'SampleRate',fs1);
har1 = dsp.AudioRecorder(...
            'DeviceName', ...
             '1-2 (OCTA-CAPTURE)',...
            'SampleRate', fs1, ...
            'NumChannels', 1,...
            'OutputDataType','double',...
            'QueueDuration', 2,...
            'SamplesPerFrame', audioFrameLength);
har2 = dsp.AudioRecorder(...
            'DeviceName', ...
             '1-2 (OCTA-CAPTURE)',...
            'SampleRate', fs1, ...
            'NumChannels', 1,...
            'OutputDataType','double',...
            'QueueDuration', 2,...
            'SamplesPerFrame', audioFrameLength);
        
while (~isDone(f1)&&~isDone(f1))
    audio1 = step(f1);
    step(fplayer1,audio1);
    ref = step(har1);
    d = filter(Pw, 1, ref);
    [y,e] = step(H,ref,d);
  
    step(fplayer2,y);

    
end




release(har1);
release(hafw1);
release(fplayer1);

release(f1);
