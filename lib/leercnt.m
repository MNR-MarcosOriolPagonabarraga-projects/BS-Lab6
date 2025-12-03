function senyals=leercnt(CNT,inicio,final)

% inicio y final en muestras

canales=1:CNT.nchannels;

bi=ceil(inicio/10);
bf=ceil(final/10);
ini=inicio-((bi-1)*10);
fin=final-((bf-1)*10);
numbloq=bf-bi+1;
offset=900+75*CNT.nchannels;

for i=1:numbloq,
    inicial=offset+((10*2*CNT.nchannels)*(bi+i-2));
    fseek(CNT.FILE.FID,inicial,-1);
    tmp=fread(CNT.FILE.FID,[10 CNT.nchannels],'int16');
    if (i==1),  % primer bloque
        for j=1:length(canales),
            senyals2(:,j)=(tmp(ini:10,j)-CNT.baseline(j))*CNT.sensivity(j)*CNT.calib(j)/204.8;
        end
        clear tmp;
    elseif (i==numbloq),   % ultimo bloque
        for j=1:length(canales),
            aux(:,j)=(tmp(1:fin,j)-CNT.baseline(j))*CNT.sensivity(j)*CNT.calib(j)/204.8;
        end
        senyals2=[senyals2;aux];
        clear aux tmp;
    else    % bloque intermedio
        for j=1:length(canales),
            aux(:,j)=(tmp(:,j)-CNT.baseline(j))*CNT.sensivity(j)*CNT.calib(j)/204.8;
        end
        senyals2=[senyals2;aux];
        clear aux tmp;
    end
end

% ordenacion de los canales de EEG
senyals(:,1)=senyals2(:,1); % canal Fp1
senyals(:,2)=senyals2(:,2); % canal Fp2
senyals(:,3)=senyals2(:,11); % canal F7
senyals(:,4)=senyals2(:,3); % canal F3
senyals(:,5)=senyals2(:,17); % canal Fz
senyals(:,6)=senyals2(:,4); % canal F4
senyals(:,7)=senyals2(:,12); % canal F8
senyals(:,8)=senyals2(:,26); % canal FT7
senyals(:,9)=senyals2(:,22); % canal FC3
senyals(:,10)=senyals2(:,23); % canal FC4
senyals(:,11)=senyals2(:,27); % canal FT8
senyals(:,12)=senyals2(:,13); % canal T3
senyals(:,13)=senyals2(:,5); % canal C3
senyals(:,14)=senyals2(:,18); % canal Cz
senyals(:,15)=senyals2(:,6); % canal C4
senyals(:,16)=senyals2(:,14); % canal T4
senyals(:,17)=senyals2(:,28); % canal TP7
senyals(:,18)=senyals2(:,24); % canal CP3
senyals(:,19)=senyals2(:,25); % canal CP4
senyals(:,20)=senyals2(:,29); % canal TP8
senyals(:,21)=senyals2(:,15); % canal T5
senyals(:,22)=senyals2(:,7); % canal P3
senyals(:,23)=senyals2(:,19); % canal Pz
senyals(:,24)=senyals2(:,8); % canal P4
senyals(:,25)=senyals2(:,16); % canal T6
senyals(:,26)=senyals2(:,30); % canal PO3
senyals(:,27)=senyals2(:,31); % canal PO4
senyals(:,28)=senyals2(:,9); % canal O1
senyals(:,29)=senyals2(:,10); % canal O2
senyals(:,30)=senyals2(:,20); % canal LEFTmastoid
senyals(:,31)=senyals2(:,21); % canal RIGHTmastoid
%senyals(:,30)=senyals2(:,32); % canal VEOG
%
% NO activa cuando se realiza el tema de filtrado BSS para señales neurolepticos
%senyals(:,30)=-senyals2(:,32); % canal VEOG