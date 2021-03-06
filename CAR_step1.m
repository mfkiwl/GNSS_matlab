function [Ncom1] = CAR_step1(obs_types, time_interval)
const;
load('dane_do_test.mat')
epochs = gpsSecondsFirst:time_interval:gpsSecondsLast;
dtrec_idx = 1;
com1 = [0 0 1 -1];
com2 = [0 1 -1 0];
com3 = [1 -1 0 0];
com4 = [0 0 0 1];
D = [com1; com2; com3; com4];
phase_freq = [fE1 fE6 fE7 fE5];
% C = D^-1;

    for i=1:length(epochs)
        
        %% STEP 1
        
        [L, ~, DU, CL, obs_qty] = create_obs_matrices(epochs(i), obs_types, dtrec_idx);

        B = B_matrix_CAR(1, obs_qty);

        B = [B];
        ATCA = DU' * (CL)^-1 * DU;
        ATCB = DU' * (CL)^-1 * B;
        BTCA = B' * (CL)^-1 * DU;
        BTCB = B' * (CL)^-1 * B;

        ATCL = DU' * (CL)^-1 * L;
        BTCL = B' * (CL)^-1 * L;

        M1 = [ATCA ATCB; BTCA BTCB];
        M2 = [ATCL; BTCL];

        % x_float
        xN = M1^-1 * M2;

        x_float(:,i) = xN(1:3);
        N_float = xN(4:3+str2double(obs_qty(1,2)));

        Cv = M1^-1; 
        Cx = Cv(1:3,1:3);
        Cn = Cv(4:3+str2double(obs_qty(1,2)),4:3+str2double(obs_qty(1,2)));

        [N_fixed,sqnorm,~,~,~,~,~]=LAMBDA(N_float, Cn);  %
        ratio(i) = sqnorm(:,2)./sqnorm(:,1);
        N_fixed1 = N_fixed(:,1); % pierwsza kolumna z Nfixed

        Ncom1 = N_fixed1;

        %% STEP 2
%            ["C1C" "L1C" "C6C" "L6C" "C7Q" "L7Q" "C5Q" "L5Q"];
        
        [L4, ~, DU34, CL34, obs_qty34] = create_obs_matrices(epochs(i), ["L5Q"], dtrec_idx);
        [L3, ~, ~, ~, ~] = create_obs_matrices(epochs(i), ["L7Q"], dtrec_idx);
        
        L4 = L4 * phase_freq(4)/c;
        L3 = L3 * phase_freq(3)/c;        
        [lam_com1] = get_com_lambda(1);
        Lcom1 = (L3 - L4)*lam_com1;
        Lcom1 = Lcom1 - Ncom1*lam_com1;
        [L, ~, DU, CL, obs_qty] = create_obs_matrices(epochs(i), ["L1C" "L6C" "L7Q"], dtrec_idx);
        
        obs_qty = [obs_qty34; obs_qty];
        
        B = B_matrix_CAR(2, obs_qty);
        
        L = L - repmat(Ncom1, 3,1)*lam_com1;
        L = [Lcom1; L];
        DU = [DU34; DU];
        CL = blkdiag(CL34, CL);     
        B = [B];
        ATCA = DU' * (CL)^-1 * DU;
        ATCB = DU' * (CL)^-1 * B;
        BTCA = B' * (CL)^-1 * DU;
        BTCB = B' * (CL)^-1 * B;

        ATCL = DU' * (CL)^-1 * L;
        BTCL = B' * (CL)^-1 * L;

        M1 = [ATCA ATCB; BTCA BTCB];
        M2 = [ATCL; BTCL];

        % x_float
        xN = M1^-1 * M2;
        
        x_float(:,i) = xN(1:3);
        N_float = xN(4:3+str2double(obs_qty(1,2)));
        Cv = M1^-1; 
        Cx = Cv(1:3,1:3);
        Cn = Cv(4:3+str2double(obs_qty(1,2)),4:3+str2double(obs_qty(1,2)));
        [N_fixed,sqnorm,~,~,~,~,~]=LAMBDA(N_float, Cn);  %
        ratio(i) = sqnorm(:,2)./sqnorm(:,1);
        N_fixed1 = N_fixed(:,1);
        Ncom2 = N_fixed1;
        
        
        %% STEP 3
        %            ["C1C" "L1C" "C6C" "L6C" "C7Q" "L7Q" "C5Q" "L5Q"];
        % l3 i l4 juz s� 
        [L2, ~, DU2, CL2, obs_qty2] = create_obs_matrices(epochs(i), ["L6C"], dtrec_idx);
        L2 = L2 * phase_freq(2)/c;
        [lam_com2] = get_com_lambda(2);
        [lam_trans1] = get_com_lambda(4);
        Lcom2 = (L2 - L3)*lam_com2;
        Ltrans1 = 5*Lcom2 + 4*Lcom1;
        Ntrans1 = 5*Ncom2 + 4*Ncom1;
        Ltrans1 = Ltrans1 - Ntrans1*lam_trans1;
        
        [L, ~, DU, CL, obs_qty] = create_obs_matrices(epochs(i), ["L1C" "L6C" "L7Q"], dtrec_idx);        
        obs_qty = [obs_qty2; obs_qty];
        
        B = B_matrix_CAR(3, obs_qty);
        
        minus = [repmat(Ncom1, 2,1)*lam_com1- repmat(Ncom2, 2,1)*lam_com2;...
            repmat(Ncom1, 1,1)*lam_com1];
        L = L - minus;
        L = [Ltrans1; L];
        DU = [DU2; DU];
        CL = blkdiag(CL2, CL);     
        
        ATCA = DU' * (CL)^-1 * DU;
        ATCB = DU' * (CL)^-1 * B;
        BTCA = B' * (CL)^-1 * DU;
        BTCB = B' * (CL)^-1 * B;

        ATCL = DU' * (CL)^-1 * L;
        BTCL = B' * (CL)^-1 * L;

        M1 = [ATCA ATCB; BTCA BTCB];
        M2 = [ATCL; BTCL];

        % x_float
        xN = M1^-1 * M2;
        
        x_float(:,i) = xN(1:3);
        N_float = xN(4:3+str2double(obs_qty(1,2)));
        Cv = M1^-1; 
        Cx = Cv(1:3,1:3);
        Cn = Cv(4:3+str2double(obs_qty(1,2)),4:3+str2double(obs_qty(1,2)));
        [N_fixed,sqnorm,~,~,~,~,~]=LAMBDA(N_float, Cn);  %
        ratio(i) = sqnorm(:,2)./sqnorm(:,1);
        N_fixed1 = N_fixed(:,1);
        Ncom3 = N_fixed1;
        
        
        %% STEP 4
        
        [L1, ~, DU1, CL1, obs_qty1] = create_obs_matrices(epochs(i), ["L1C"], dtrec_idx);
        L1 = L1 * phase_freq(1)/c;
        [lam_com3] = get_com_lambda(2);
        Lcom3 = (L1 - L2)*lam_com3;
        [lam_trans2] = get_com_lambda(5);
        Ltrans2 = 5*Lcom3 + 5*Lcom2 + 3*Lcom1;
        Ntrans2 = 5*Ncom3 + 5*Ncom2 + 3*Ncom1;
        Ltrans2 = Ltrans2 - Ntrans2*lam_trans2;
        
        [L, ~, DU, CL, obs_qty] = create_obs_matrices(epochs(i), ["L1C" "L6C" "L7Q"], dtrec_idx);        
        obs_qty = [obs_qty1; obs_qty];
        
        B = B_matrix_CAR(4, obs_qty);
        
        L = L - [Ncom1-Ncom2-Ncom3; Ncom1-Ncom2; Ncom1];
        L = [Ltrans2; L];
        DU = [DU1; DU];
        CL = blkdiag(CL1, CL);     
        
        ATCA = DU' * (CL)^-1 * DU;
        ATCB = DU' * (CL)^-1 * B;
        BTCA = B' * (CL)^-1 * DU;
        BTCB = B' * (CL)^-1 * B;

        ATCL = DU' * (CL)^-1 * L;
        BTCL = B' * (CL)^-1 * L;

        M1 = [ATCA ATCB; BTCA BTCB];
        M2 = [ATCL; BTCL];

        % x_float
        xN = M1^-1 * M2;
        
        x_float(:,i) = xN(1:3);
        N_float = xN(4:3+str2double(obs_qty(1,2)));
        Cv = M1^-1; 
        Cx = Cv(1:3,1:3);
        Cn = Cv(4:3+str2double(obs_qty(1,2)),4:3+str2double(obs_qty(1,2)));
        [N_fixed,sqnorm,~,~,~,~,~]=LAMBDA(N_float, Cn);  %
        ratio(i) = sqnorm(:,2)./sqnorm(:,1);
        N_fixed1 = N_fixed(:,1);
        N4 = N_fixed1;
        
        dtrec_idx = dtrec_idx + 1;
    end
    
end

