% t0=datenum(2017,12,01);                   % date number by datenum.m (days)
% time=gpsSecondsFirst:1:gpsSecondsLast;                   % estimation time vector relative to t0 (sec)
maska=10;                                % maska w stopniach

% Sto={'GNIE131E.11o','WROC131E.11o'};     %ref %rov
% Stn={'BOR1131E.11n'};  % to efemerydy eph

xp=[3655332.7218, 1403901.2678, 5018038.6137;...% ref
    3655332.7217, 1403901.2599, 5018038.6545];  % rov
%% numery warstw z obserwacjami w obsMAtrix
codes = ["C1C", "C5Q"];
i_C1C = find(string(obsType(:))==codes(1));
i_C5Q = find(string(obsType(:))==codes(2));

%%
% files={char(Sto(1)),char(Stn)};
% files_r={char(Sto(2)),char(Stn)};

% [obs,iobs,nav,inav]=readrnx(t0,time(1),time(end),files);
% [obsr,iobsr]=readrnx(t0,time(1),time(end),files_r);

for k=1:length(time)
    %pozycja SPP ref
    i=find(cell2mat(obsTable(:,1))==time(k)); % numer wiersza epoki w obsMatrix
    obsk=obs(i,:); % obserwacje
    iobsk=iobs(i,:); % obserwacje info 
    [rr_a,t(k),dtb(k),DOP(k)]=pointp(t0,obsk,iobsk,nav,inav,maska,xp(1,:)');
    r_a(k,:)=rr_a';
    
    %pozycja SPP rov
    i=find(round(iobsr(:,1))==time(k)); 
    obskr=obsr(i,:); 
    iobskr=iobsr(i,:);
    [rr_b,t(k),dtr(k)]=pointp(t0,obskr,iobskr,nav,inav,maska,xp(2,:)');
    r_b(k,:)=rr_b';
    
    %poprawka DGPS, pozycja DGPS rov
    PRC=vpr(t0,t(k),dtb(k),obsk,iobsk,nav,inav,xp(1,:)');
    [c,i,j]=intersect(PRC(:,3),iobskr(:,2)); 
    obskr=obskr(j,:); 
    iobskr=iobskr(j,:); 
    PRC=PRC(i,:);
    obskr(:,3)=obskr(:,3)+PRC(:,1);
    obskr(:,4)=obskr(:,4)+PRC(:,2);
    [rr_r]=pointp_P(t0,obskr,iobskr,nav,inav,maska,xp(2,:)');
    r_r(k,:)=rr_r';
end
    
    