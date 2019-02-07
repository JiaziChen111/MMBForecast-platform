Vintages = {'Vintages','Available','Missing Variables'};

Vintages(2,:) = {[],[],[]};
temp = basics.chosenmodels;
basics.windowlength = basics.windowlength+basics.inspf;

% basics.nvar = 3*basics.inspf+(1-basics.inspf)*basics.nvar;

for vint = (2+(basics.region(find(basics.chosenmodels>0))==2)):size(DATAMAT{1}(1,:),2)-basics.vintrev*(basics.vintrev>1)-basics.inspf-basics.fnc
    
    a = cellstr(DATAMAT{1}(1,vint)); a = a{1}; m = size(a,2)-3; vintagename = get_vint_name(a);
    
    Vintages(vint,1) = {vintagename};
    
    l = find(strcmp(VINTAGES,{[a(m:m+1) 'Q' a(end)]})==1)-1-(basics.region(find(basics.chosenmodels>0))==2);
    
    position_LastObs = find(strcmp(DATAMAT{1}(:,1),OBSERVATION(l,:))==1);
    
    position_FirstObs = position_LastObs-basics.windowlength+1;
    
    missing = zeros(1,basics.nvar);
    
    for n = 1:basics.nvar
        if (basics.inspf == 1 && (n<4 || n == basics.nvar))
            for i = position_FirstObs:position_LastObs+basics.inspf
                if ((cell2mat(DATAMAT{n}(i,vint))==-99)||(cell2mat(DATAMAT{n}(i,vint))==-999))
                    missing(n) = 1;
                end
            end
        else
            for i = position_FirstObs:position_LastObs
                if ((cell2mat(DATAMAT{n}(i,vint))==-99)||(cell2mat(DATAMAT{n}(i,vint))==-999))
                    missing(n) = 1;
                end
            end
        end
    end
    if isempty(find(missing(modelvars_index)==1))
        
        Vintages(vint,2) = cellstr('yes');
        VintData = DATAMAT{1}([1 position_FirstObs:position_LastObs+basics.inspf+basics.fnc],1);
        
        
        % Here we need to delete the : in the date otherwise dynare cannot
        % find the dates!
        VintData = regexprep(VintData,':','');
        VintData{1,1} = [];
        
        
        for i = 1:basics.nvar
            if basics.inspf == 1
                if ( basics.modelvars(i) &&  (i<4 || i == basics.nvar)) % First 3 variables and the credit spread constitutes the SPF NC
                    VintData = [VintData [cell2mat(basics.observables{i});DATAMAT{i}(position_FirstObs:position_LastObs+basics.inspf,vint)]];
                elseif basics.modelvars(i) 
                    VintData = [VintData [cell2mat(basics.observables{i});[DATAMAT{i}(position_FirstObs:position_LastObs,vint); NaN ]]];
                end
            elseif basics.fnc == 1
                if ( basics.modelvars(i) &&  (i==3 || i == basics.nvar)) % Short term rate and creadit spread
                    VintData = [VintData [cell2mat(basics.observables{i});DATAMAT{i}(position_FirstObs:position_LastObs+basics.fnc,vint)]];
                elseif basics.modelvars(i)
                    VintData = [VintData [cell2mat(basics.observables{i});[DATAMAT{i}(position_FirstObs:position_LastObs,vint); NaN ]]];
                end
            else
                if  basics.modelvars(i)
                    VintData = [VintData [cell2mat(basics.observables{i});DATAMAT{i}(position_FirstObs:position_LastObs,vint)]];
                end
            end
        end
        
        xlswrite([basics.location '\ExcelFileVintages\' vintagename],VintData,1)
    else
        Vintages(vint,2) = cellstr('no');
        
        Vintages(vint,3) = get_missing_var(missing);
    end
end
basics.chosenmodels = temp;
clear temp
xlswrite([basics.location '\ExcelFileVintages\Vintages Available'], Vintages);
basics.windowlength = basics.windowlength-basics.inspf;
