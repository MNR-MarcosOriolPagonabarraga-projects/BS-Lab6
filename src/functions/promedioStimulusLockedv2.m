function tablaSEN=promedioStimulusLockedv2(name,pareja,canal,sigma)

% con Stimulus-locked se genera una ventana alineada en el estímulo de -400ms a +1000ms (se puede ver el potencial visual P300
% canal: numero de canal... recomendados para ver mejor el P300 5 (Fz) 14 (Cz) 23 Pz
% pareja: flanker test: estimulo-respuesta... codificaciones correctas pareja=[1 1;2 1;3 8;4 8]
% tablaSEN: tabla formado por todos los trials libres de artefacto que cumple con las condiciones de estimulo-respuesta especificadas en pareja 

CNT=abrircnt(name);

%xmin=input('Introduce el numero de ms anterior a la respuesta para formar la ventana: ');
%xmax=input('Introduce el numero de ms posterior a la respuesta para formar la ventana: ');
xmin=400;xmax=1000;

% ms de correccion de linea base 100ms 
msbase=100;

% umbral trail artefactuado si supera 75uV
umbral=75;
[numeroparejas,auxiliar]=size(pareja);
nepoc=0;
for numpar=1:numeroparejas,
    estimulo=pareja(numpar,1);
    respuesta=pareja(numpar,2);
    num_muestras=(CNT.eventtablepos-900-(75*CNT.nchannels))/(2*CNT.nchannels);
    ok=0;
    vec_estim=find(CNT.event(:,1)==estimulo);
    for i=1:length(vec_estim),
        if (vec_estim(i)+1)<=length(CNT.event),
            if (CNT.event(vec_estim(i),1)==estimulo) & (CNT.event(vec_estim(i)+1,2)==respuesta),
                diferencia=(CNT.event(vec_estim(i)+1,3)-CNT.event(vec_estim(i),3))*1000/CNT.rate;
                ok=1;
                if (diferencia<100) | (diferencia>600),
                    ok=0;
                end
            end
        end
        if (ok==1),
            des= round(random('Normal',0,sigma));
            inicio=CNT.event(vec_estim(i),3)+des-round(xmin*CNT.rate/1000)+1;
            final=CNT.event(vec_estim(i),3)+des+round(xmax*CNT.rate/1000);
            senyals=leercnt(CNT,inicio,final);
            %senyals2=senyals(:,canal);
            promedioMASTOIDES=mean(senyals(:,30:31)')';
            senyals2=senyals(:,canal)-promedioMASTOIDES;
            media=mean(senyals2(round(xmin*CNT.rate/1000)+1-round(msbase*CNT.rate/1000):round(xmin*CNT.rate/1000)));
            senyals2=senyals2-media;
            clear promedioMASTOIDES senyals;
            if max(max(abs(senyals2([round(xmin*CNT.rate/1000)+1+round(xmin*CNT.rate/1000):round(xmin*CNT.rate/1000)+round(xmax*CNT.rate/1000)]))))<umbral,
                nepoc=nepoc+1;
                tablaSEN(nepoc,:)=senyals2;
            end
            ok=0;
        end
    end
end
