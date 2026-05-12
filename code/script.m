% from Tobii data (tsv file in the sample folder)
% you will find fixation minimum time = 100
% and fixation radius = 20, while
% screen size 1080 1240

% the code snippets here are from IEICE  technical report of Japan.
% Yamasaki et al., 2015. Yamasaki, K., Itoh, T., Itoh, Y., Okazaki, S., Sadato, N., Imoto,
% K., Shishido, E., and Fukumura, N. (2015). Feature extraction of eye-hand
% coordination in tracing tasks of calligraphers. IEICE Tech. Rep., 114 (515)
% NC2014-123:313–318.

% theory_data from 'ModelTrajectory_new0803.mat'
% Store the minimum distance between measured and theoretical positions
% in the variables min_tobii and min_pen.
% the pixcel value of x and y are converted to the real size (mm)
% according to the display monitor's size and aspect ratio.

measure_data(1:data_end-data_start+1,1) = GazePointX(data_start:data_end,1);
measure_data(1:data_end-data_start+1,2) = GazePointY(data_start:data_end,1);
measure_data(1:data_end-data_start+1,3) = Pentime(data_start:data_end,1);
measure_data(1:data_end-data_start+1,4) = PenX(data_start:data_end,1);
measure_data(1:data_end-data_start+1,5) = PenY(data_start:data_end,1);

time = measure_data(:,3)-measure_data(1,3);%運動時間を0から表示するようにしてる

 %計測位置と理論位置の距離の最小値をmin_に保存
for i = 1:size(measure_data,1)%data_end-data_start+1
    for j = 1:size (theory_data,1)
        tobii(j,i) = sqrt((measure_data(i,1)-theory_data(j,2))^2+(measure_data(i,2)-(theory_data(j,3)))^2)*0.318;
        pen(j,i) = sqrt((measure_data(i,4)-theory_data(j,2))^2+(measure_data(i,5)-(theory_data(j,3)))^2)*0.318;
    end
    min_tobii(i,:)=min(tobii(:,i)); % minmum distance from the center of target line, for each data point
    min_pen(i,:)=min(pen(:,i)); % minmum distance from the center of target line, for each data point
end

%外れ値の除去
for i = 1:size(measure_data,1)
    if min_tobii(i,1)>70     %  threshold 70 mm
        min_tobii(i,1) = NaN;
    end
end
    
% minimumになった時の、対応するtarget軌道上の距離を入力
for i = 1:size(measure_data,1)
    for j = 1:size (theory_data,1)
        if tobii(j,i) == min_tobii(i,1)
            new_measure_data(i,1) = 0.316*theory_data(j,2); % x axis
            new_measure_data(i,2) = 0.32*(theory_data(j,3)); % y axis
            new_measure_data(i,3) = 0.318*theory_data(j,4); % distance
        end
        
        if pen(j,i) == min_pen(i,1)
            new_measure_data(i,4) = 0.316*theory_data(j,2);
            new_measure_data(i,5) = 0.32*(theory_data(j,3));
            new_measure_data(i,6) = 0.318*theory_data(j,4);
        end
    end
end

% detect outlier and replace with nan
if min_tobii(i,1)>70     %  mm
        min_tobii(i,1) = NaN;
end

% 時間先行量算出
for i = 1:size(measure_data,1)
    for j = 1:size(measure_data,1)
        time(j,i) = abs(new_measure_data(i,3)-new_measure_data(j,6));
    end
    min_time(i,:)=min(time(:,i));
end

for i = 1:size(new_measure_data,1)
    for j = 1:size(new_measure_data,1)
        if time(j,i) == min_time(i,1)
            gaze_proceed_time(i,9) = time(j)-time(i);
        end
    end
end

% gaze-pen距離の計算
for i = 1:size(measure_data,1)
    new_measure_data(i,7) = new_measure_data(i,3)-new_measure_data(i,6);
    if min_pen(i,1)>50
        min_pen(i,1) = NaN;
    end
end

% 時間先行量の補正
for i = 1:size(measure_data,1)
    if abs(new_measure_data(i,9)) > 1500 || isnan(new_measure_data(i,1))
        new_measure_data(i,9) = NaN;
    end
end

% Gaze速度の算出 mm/s
for i = 2:size(measure_data,1)-1%data_end-data_start
    new_measure_data(i,22) = abs(new_measure_data(i+1,3)-new_measure_data(i-1,3))/abs(Timestamp(data_start+i)-Timestamp(data_start+i-2))*1000;
end

% detectiono of saccade by gaze speed
% the distacne between eyes and display is around 500 mm
for i = 2:gaze_end 
    if (isnan(new_measure_data(i,23)))||...
            ((new_measure_data(i,23) ~= new_measure_data(i+1,23)&&isnan(new_measure_data(i+1,23))==0))||...
            ((new_measure_data(i,23) ~= new_measure_data(i-1,23)&&isnan(new_measure_data(i-1,23))==0))%Indexが空いてたら，もしくは，Indexの数字が切り替わったら
        if (new_measure_data(i,22) >= 310.0131345) && (abs(new_measure_data(i-1,3) - new_measure_data(i+1,3)) >= 6.981770725)
            new_measure_data(i-1:i+1,16) = 150; % 150 is a numerical code for saccade
            new_measure_data(i-1:i+1,19) = new_measure_data(i-1:i+1,3);
        end
    end
   % サッカードのはじめが切れてた場合
    if isnan(new_measure_data(i-1,1)) && (new_measure_data(i+1,22) >= 310.0131345) &&...
            abs(new_measure_data(i,3) - new_measure_data(i+1,3)) >= 6.981770725
        new_measure_data(i:i+1,16) = 150;
        new_measure_data(i:i+1,19) = new_measure_data(i:i+1,3);
    end
    % サッカードの終わりが切れてた場合
    if isnan(new_measure_data(i+1,1)) && (new_measure_data(i-1,22) >= 310.0131345) &&...
            abs(new_measure_data(i,3) - new_measure_data(i-1,3)) >= 6.981770725
        new_measure_data(i-1:i,16) = 150;
        new_measure_data(i-1:i,19) = new_measure_data(i-1:i,3);
    end
    % saccade のはじめと終わりを求める
    if numel(find(new_measure_data(:,16) == 150)) == 0 %%サッカードしてないとき
        saccade_start(k,1) = gaze_end;
        saccade_end(k,1) = gaze_start;
    else
        saccade(k,:) = find(new_measure_data(gaze_start:gaze_end,16) == 150)+gaze_start-1; %%サッカードと判定されたIndexを抽出
        saccade_start(k,1) = saccade(k,1); %%%%%%%%%%サッカードの始まる時刻。初めにサッカードが起きた時間を代入
        
        if gaze_start > 1
            saccade_end(k,1) = gaze_start;  %%%%%%%サッカードの終了時刻を入れる。最初なので運動のはじめを代入
        else saccade_end(k,1) = 2;
        end
        
        j = 1;
        for i = 1:size(saccade,2)
            if saccade(k,i)-saccade_start(k,j)>=10 %%サッカードが10データ以上続く、またはサッカードの間が10データ以下だとココの条件は破綻。
                j = j + 1;
                saccade_start(k,j) = saccade(k,i);
                saccade_end(k,j) = saccade(k,i-1);
                Saccade_count(k,1) = Saccade_count(k,1)+1;
                saccade_move_distance(k,j-1) = new_measure_data(saccade_end(k,j),3)-new_measure_data(saccade_start(k,j-1),3); %サッカード距離
            end
            saccade_start(k,j+1) = gaze_end;
            saccade_end(k,j+1) = find(new_measure_data(:,16) == 150,1,'last');
            saccade_move_distance(k,j) = new_measure_data(saccade_end(k,j+1),3)-new_measure_data(saccade_start(k,j),3);
        end
        saccade_start(saccade_start == 0) = NaN;
        saccade_end(saccade_end == 0) = NaN;
        saccade_move_distance(saccade_move_distance == 0) = NaN;
    end
end

% Detection of fixation and pursuit
for i = 1:size(saccade_end,2)
    if isnan(saccade_start(k,i)) == 0 
        saccade_time_distance(k,i) = abs(Timestamp(data_start+saccade_start(k,i)-1)-Timestamp(data_start+saccade_end(k,i)+1));
        gaze_distance = abs(new_measure_data(saccade_start(k,i)-1,3)-new_measure_data(saccade_end(k,i)+1,3));
        gaze_speed = gaze_distance/saccade_time_distance(k,i);
        pen_distance = abs(new_measure_data(saccade_start(k,i)-1,6)-new_measure_data(saccade_end(k,i)+1,6));
        pen_speed = pen_distance/saccade_time_distance(k,i);
        
        if gaze_speed/pen_speed <= 0.4 || gaze_distance <= 6.981770725
            new_measure_data(saccade_end(k,i)+1:saccade_start(k,i)-1,16) = 50;
            new_measure_data(saccade_end(k,i)+1:saccade_start(k,i)-1,17) = new_measure_data(saccade_end(k,i)+1:saccade_start(k,i)-1,3);
        else
            new_measure_data(saccade_end(k,i)+1:saccade_start(k,i)-1,16) = 100;
            new_measure_data(saccade_end(k,i)+1:saccade_start(k,i)-1,18) = new_measure_data(saccade_end(k,i)+1:saccade_start(k,i)-1,3);
        end
    end
end

saccade_time_distance(saccade_time_distance == 0) = NaN;

% 補間できなかった区間について
if numel(datapoint(~nanidx)) ~= 0
    for i = 1:size(Nan_end,2)
        if Nan_flag(1,i) == 1
            for j = Nan_start(1,i):-1:gaze_start
                if new_measure_data(j,16) == 150 || j == gaze_start ||...
                        (i>= 2 && j == Nan_end(1,i-1) && Nan_flag(1,i-1) == 1) %サッカードがなければ、補完できてない最初の点まで探索。フラグが0のところは補間できてる
                    gaze_distance = abs(new_measure_data(Nan_start(1,i),3)-new_measure_data(j+1,3));
                    gaze_speed = gaze_distance/abs(Timestamp(data_start+Nan_start(1,i))-Timestamp(data_start+j+1));
                    pen_distance = abs(new_measure_data(Nan_start(1,i),6)-new_measure_data(j+1,6));
                    pen_speed = pen_distance/abs(Timestamp(data_start+Nan_start(1,i))-Timestamp(data_start+j+1));
                    if gaze_speed/pen_speed <= 0.4 || gaze_distance <= 6.981770725
                        new_measure_data(j+1:Nan_start(1,i),16) = 50;
                        new_measure_data(j+1:Nan_start(1,i),17:19) = NaN;
                        new_measure_data(j+1:Nan_start(1,i),17) = new_measure_data(j+1:Nan_start(1,i),3);
                    else
                        new_measure_data(j+1:Nan_start(1,i),16) = 100;
                        new_measure_data(j+1:Nan_start(1,i),17:19) = NaN;
                        new_measure_data(j+1:Nan_start(1,i),18) = new_measure_data(j+1:Nan_start(1,i),3);
                    end
                    break;
                end
            end
            
            for j = Nan_end(1,i):gaze_end
                if new_measure_data(j,16) == 150 || j == gaze_end || (i>= 2 && j == Nan_start(1,i+1) && Nan_flag(1,i+1) == 1)
                    gaze_distance = abs(new_measure_data(Nan_end(1,i),3)-new_measure_data(j-1,3));
                    gaze_speed = gaze_distance/abs(Timestamp(data_start+Nan_end(1,i))-Timestamp(data_start+j-1));
                    pen_distance = abs(new_measure_data(Nan_end(1,i),6)-new_measure_data(j-1,6));
                    pen_speed = pen_distance/abs(Timestamp(data_start+Nan_end(1,i))-Timestamp(data_start+j-1));
                    if gaze_speed/pen_speed <= 0.4 || gaze_distance <= 6.981770725
                        new_measure_data(Nan_end(1,i):j-1,16) = 50;
                        new_measure_data(Nan_end(1,i):j-1,17:19) = NaN;
                        new_measure_data(Nan_end(1,i):j-1,17) = new_measure_data(Nan_end(1,i):j-1,3);
                    else
                        new_measure_data(Nan_end(1,i):j-1,16) = 100;
                        new_measure_data(Nan_end(1,i):j-1,17:19) = NaN;
                        new_measure_data(Nan_end(1,i):j-1,18) = new_measure_data(Nan_end(1,i):j-1,3);
                    end
                    break;
                end
            end
        end
    end
end

 % サッカード直後の先行量計算
j = 1;
for i = 2:size(saccade_end,2)
    if isnan(saccade_end(k,i))==0
        point_precedence(k,j) = new_measure_data(saccade_end(k,i),7);
        time_precedence(k,j) = new_measure_data(saccade_end(k,i),9);
        j = j + 1;
    end
end
point_precedence(point_precedence==0)=NaN;
time_precedence(time_precedence==0)=NaN;
%%
for i = 1:size(measure_data,1)%data_end-data_start+1
    if new_measure_data(i,17) == 0
        new_measure_data(i,17) = NaN;
    end
    if new_measure_data(i,18) == 0
        new_measure_data(i,18) = NaN;
    end
    if new_measure_data(i,19) == 0
        new_measure_data(i,19) = NaN;
    end
    if isnan(new_measure_data(i,1))
        new_measure_data(i,16) = NaN;
    end
end

% smoothing of pen data, unit pixel
PenRawX=PenX(data_start:data_end);  % pixel

measure_data(1:data_end-data_start+1,4)=PenRawX; 
        for num=3:data_end-data_start-2
        measure_data(num,4) =(PenRawX(num-2)+PenRawX(num-1)+PenRawX(num)+PenRawX(num+1)+PenRawX(num+2))/5; % smoothing span=5
        end
PenSmoX= measure_data(:,4);    

PenRawY=-PenY(data_start:data_end)+900; % pixel
measure_data(1:data_end-data_start+1,5)=PenRawY; 
            for num=3:data_end-data_start-2
            measure_data(num,5) =(PenRawY(num-2)+PenRawY(num-1)+PenRawY(num)+PenRawY(num+1)+PenRawY(num+2))/5; % smoothing span=5
            end
PenSmoY= measure_data(:,5);

% target line x y distance from start
load('ModelTrajectory_new0803.mat');
    switch GifName
        case 'L1-1'
            theory_data(:,1) = VarName1;theory_data(:,2) = VarName2;theory_data(:,3) = VarName3;theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L1-2'
            theory_data(:,1) = VarName5; theory_data(:,2) = VarName6; theory_data(:,3) = VarName7; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L1-3'
            theory_data(:,1) = VarName9; theory_data(:,2) = VarName10; theory_data(:,3) = VarName11; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L2-1'
            theory_data(:,1) = VarName13; theory_data(:,2) = VarName14; theory_data(:,3) = VarName15; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L2-2' 
            theory_data(:,1) = VarName17; theory_data(:,2) = VarName18; theory_data(:,3) = VarName19; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L2-3'
            theory_data(:,1) = VarName21; theory_data(:,2) = VarName22; theory_data(:,3) = VarName23; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L3-1'
            theory_data(:,1) = VarName25; theory_data(:,2) = VarName26; theory_data(:,3) = VarName27; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L3-2'
            theory_data(:,1) = VarName29; theory_data(:,2) = VarName30; theory_data(:,3) = VarName31; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'L3-3'
            theory_data(:,1) = VarName33; theory_data(:,2) = VarName35; theory_data(:,3) = VarName36; theory_data(:,4) = VarName0; %←←←それなりの曲線に直した20150803宍戸
        case 'S1-1-1'
            theory_data(:,1) = VarName34; theory_data(:,2) = VarName38; theory_data(:,3) = VarName39; theory_data(:,4) = VarName40;
        case 'S1-1-2'
            theory_data(:,1) = VarName41; theory_data(:,2) = VarName42; theory_data(:,3) = VarName43; theory_data(:,4) = VarName44;
        case 'S1-1-3'
            theory_data(:,1) = VarName45; theory_data(:,2) = VarName46; theory_data(:,3) = VarName47; theory_data(:,4) = VarName48;
        case 'S1-2-1'
            theory_data(:,1) = VarName49; theory_data(:,2) = VarName50; theory_data(:,3) = VarName51; theory_data(:,4) = VarName52;
        case 'S1-2-2'
            theory_data(:,1) = VarName53; theory_data(:,2) = VarName54; theory_data(:,3) = VarName55; theory_data(:,4) = VarName56;
        case 'S1-2-3'
            theory_data(:,1) = VarName57; theory_data(:,2) = VarName58; theory_data(:,3) = VarName59; theory_data(:,4) = VarName60;
        case 'S2-1-1'
            theory_data(:,1) = VarName61; theory_data(:,2) = VarName62; theory_data(:,3) = VarName63; theory_data(:,4) = VarName64;
        case 'S2-1-2'
            theory_data(:,1) = VarName65; theory_data(:,2) = VarName66; theory_data(:,3) = VarName67; theory_data(:,4) = VarName68;
        case 'S2-1-3'
            theory_data(:,1) = VarName69; theory_data(:,2) = VarName70; theory_data(:,3) = VarName71; theory_data(:,4) = VarName72;
        case 'S2-2-1'
            theory_data(:,1) = VarName73; theory_data(:,2) = VarName74; theory_data(:,3) = VarName75; theory_data(:,4) = VarName76;
        case 'S2-2-2'
            theory_data(:,1) = VarName77; theory_data(:,2) = VarName78; theory_data(:,3) = VarName79; theory_data(:,4) = VarName80;
        case 'S2-2-3'
            theory_data(:,1) = VarName81; theory_data(:,2) = VarName82; theory_data(:,3) = VarName83; theory_data(:,4) = VarName84;
        case 'S3-1-1'
            theory_data(:,1) = VarName85; theory_data(:,2) = VarName86; theory_data(:,3) = VarName87; theory_data(:,4) = VarName88;
        case 'S3-1-2'
            theory_data(:,1) = VarName89; theory_data(:,2) = VarName90; theory_data(:,3) = VarName91; theory_data(:,4) = VarName92;
        case 'S3-1-3'
            theory_data(:,1) = VarName93; theory_data(:,2) = VarName94; theory_data(:,3) = VarName95; theory_data(:,4) = VarName96;
        case 'S3-2-1'
            theory_data(:,1) = VarName97; theory_data(:,2) = VarName98; theory_data(:,3) = VarName99; theory_data(:,4) = VarName100;
        case 'S3-2-2'
            theory_data(:,1) = VarName101; theory_data(:,2) = VarName102; theory_data(:,3) = VarName103; theory_data(:,4) = VarName104;
        case 'S3-2-3'
            theory_data(:,1) = VarName105; theory_data(:,2) = VarName106; theory_data(:,3) = VarName107; theory_data(:,4) = VarName108;
        case 'T1-1-2-1'
            theory_data(:,1) = VarName109; theory_data(:,2) = VarName110; theory_data(:,3) = VarName111; theory_data(:,4) = VarName112;
        case 'T1-1-2-2'
            theory_data(:,1) = VarName113; theory_data(:,2) = VarName114; theory_data(:,3) = VarName115; theory_data(:,4) = VarName116;
        case 'T1-1-2-3'
            theory_data(:,1) = VarName117; theory_data(:,2) = VarName118; theory_data(:,3) = VarName119; theory_data(:,4) = VarName120;
        case 'T1-2-1-1'
            theory_data(:,1) = VarName121; theory_data(:,2) = VarName122; theory_data(:,3) = VarName123; theory_data(:,4) = VarName124;
        case 'T1-2-1-2'
            theory_data(:,1) = VarName125; theory_data(:,2) = VarName126; theory_data(:,3) = VarName127; theory_data(:,4) = VarName128;
        case 'T1-2-1-3'
            theory_data(:,1) = VarName129; theory_data(:,2) = VarName130; theory_data(:,3) = VarName131; theory_data(:,4) = VarName132;
        case 'T2-1-2-1'
            theory_data(:,1) = VarName133; theory_data(:,2) = VarName134; theory_data(:,3) = VarName135; theory_data(:,4) = VarName136;
        case 'T2-1-2-2'
            theory_data(:,1) = VarName137; theory_data(:,2) = VarName138; theory_data(:,3) = VarName139; theory_data(:,4) = VarName140;
        case 'T2-1-2-3'
            theory_data(:,1) = VarName141; theory_data(:,2) = VarName142; theory_data(:,3) = VarName143; theory_data(:,4) = VarName144;
        case 'T2-2-1-1'
            theory_data(:,1) = VarName145; theory_data(:,2) = VarName146; theory_data(:,3) = VarName147; theory_data(:,4) = VarName148;
        case 'T2-2-1-2'
            theory_data(:,1) = VarName149; theory_data(:,2) = VarName150; theory_data(:,3) = VarName151; theory_data(:,4) = VarName152;
        case 'T2-2-1-3'
            theory_data(:,1) = VarName153; theory_data(:,2) = VarName154; theory_data(:,3) = VarName155; theory_data(:,4) = VarName156;
        case 'T3-1-2-1'
            theory_data(:,1) = VarName157; theory_data(:,2) = VarName158; theory_data(:,3) = VarName159; theory_data(:,4) = VarName160;
        case 'T3-1-2-2'
            theory_data(:,1) = VarName161; theory_data(:,2) = VarName162; theory_data(:,3) = VarName163; theory_data(:,4) = VarName164;
        case 'T3-1-2-3'
            theory_data(:,1) = VarName165; theory_data(:,2) = VarName166; theory_data(:,3) = VarName167; theory_data(:,4) = VarName168;
        case 'T3-2-1-1'
            theory_data(:,1) = VarName169; theory_data(:,2) = VarName170; theory_data(:,3) = VarName171; theory_data(:,4) = VarName172;
        case 'T3-2-1-2'
            theory_data(:,1) = VarName173; theory_data(:,2) = VarName174; theory_data(:,3) = VarName175; theory_data(:,4) = VarName176;
        case 'T3-2-1-3'
            theory_data(:,1) = VarName177; theory_data(:,2) = VarName178; theory_data(:,3) = VarName179; theory_data(:,4) = VarName180;
        otherwise
            %theory_data(1:1001,1:4) = zeros;
    end


TheoryTime=theory_data(:,1);
TheoryX=theory_data(:,2);
TheoryY=theory_data(:,3);
TheoryL=theory_data(:,4);

% Curvature is the reciprocal of the radius of curvature
[InvR, V]=curvature(TheoryX, TheoryY);

