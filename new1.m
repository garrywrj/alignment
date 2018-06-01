%--------查看设备名称-----------
info = audiodevinfo;
name = info.input(2).Name;
Micrname = sprintf('%s',name);
clear all
fs = 16000;
audioFrameLength = 1024;    
nChan = 2;
ith = 1;
filename1 = '陶喆 - 蝴蝶.mp3';


[freader1,fs1]  = audioread(filename1);%freader1  speech

freader1 = freader1(:,1);


f1 = dsp.SignalSource(freader1,'SamplesPerFrame',1024);


%freader1  = dsp.AudioFileReader(filename1,'SamplesPerFrame',1024);

fplayer1  = dsp.AudioPlayer('DeviceName','3-4 (OCTA-CAPTURE)','SampleRate',fs1);




hafw1 = dsp.AudioFileWriter(...
            'ref_query.wav',...
            'FileFormat','wav',...
            'SampleRate',fs1);

har1 = dsp.AudioRecorder(...
            'DeviceName', ...
             '1-2 (OCTA-CAPTURE)',...
            'SampleRate', fs1, ...
            'NumChannels', 2,...
            'OutputDataType','double',...
            'QueueDuration', 2,...
            'SamplesPerFrame', audioFrameLength);
     
                
while (~isDone(f1)&&~isDone(f1))
    audio1 = step(f1);
    step(fplayer1,audio1);  %fplayer1 speech fplayer2 可以独立播放music
    step(hafw1,step(har1));

%     ref = step(har1);
%     d = filter(Pw, 1, ref);
%     [y,e] = step(H,ref,d);
%   
%     step(fplayer2,y);

    
end

release(har1);

release(hafw1);

release(fplayer1);

release(f1);
