classdef OtaMapCalibrationApp < matlab.apps.AppBase                         % OtaMapCalibrationApp is the app name  < matlab.apps.AppBase declares an app

    properties (Access = public)                                            % Public properties: usable inside the app and accessible from the command window outside the app; mostly UI components
        UIFigure matlab.ui.Figure

        aField matlab.ui.control.NumericEditField                           % matlab.ui.control.NumericEditField: numeric input field
        bField matlab.ui.control.NumericEditField

        asField matlab.ui.control.NumericEditField
        bsField matlab.ui.control.NumericEditField

        anField matlab.ui.control.NumericEditField
        bnField matlab.ui.control.NumericEditField

        startAField matlab.ui.control.NumericEditField
        startBField matlab.ui.control.NumericEditField

        startFreqField matlab.ui.control.NumericEditField
        stopFreqField  matlab.ui.control.NumericEditField
        stepFreqField  matlab.ui.control.NumericEditField

        directionDrop matlab.ui.control.DropDown                            % matlab.ui.control.DropDown: dropdown field
        mirrorDrop matlab.ui.control.DropDown

        spiOrderDrop matlab.ui.control.DropDown
        uOrderDrop matlab.ui.control.DropDown
        modeDrop matlab.ui.control.DropDown

        generateButton matlab.ui.control.Button                             % matlab.ui.control.Button: push button
        exportButton matlab.ui.control.Button
        calibrateButton matlab.ui.control.Button

        codeHexArea matlab.ui.control.TextArea                              % TextArea: a text area

        mapTable matlab.ui.control.Table                                    % Table: a table

        spiImage matlab.ui.control.Image                                    % Image: image display area
        uImage matlab.ui.control.Image
        pinImage matlab.ui.control.Image
        mirrorImage matlab.ui.control.Image
        orderImage matlab.ui.control.Image

        orderLabel matlab.ui.control.Label                                  % Plain-text label
        statusArea matlab.ui.control.TextArea
    end


    methods (Access = private)                                              % Begin private section; callable only from within the class

        function startup(app)
            app.UIFigure = uifigure( ...
                'Position',[100 100 1200 600], ...
                'Name','OTA MAP Generation & Calibration Tool');

            %% Array parameters (identical to the previous app)
            uilabel(app.UIFigure,'Position',[20 500 150 22],'Text','Array rows (elements)');
            app.aField = uieditfield(app.UIFigure,'numeric','Position',[170 500 60 22],'Value',16);

            uilabel(app.UIFigure,'Position',[250 500 150 22],'Text','Array columns (elements)');
            app.bField = uieditfield(app.UIFigure,'numeric','Position',[400 500 60 22],'Value',16);

            uilabel(app.UIFigure,'Position',[20 470 150 22],'Text','SPI rows');
            app.asField = uieditfield(app.UIFigure,'numeric','Position',[170 470 60 22],'Value',2);

            uilabel(app.UIFigure,'Position',[250 470 150 22],'Text','SPI columns');
            app.bsField = uieditfield(app.UIFigure,'numeric','Position',[400 470 60 22],'Value',2);

            uilabel(app.UIFigure,'Position',[20 440 150 22],'Text','U rows per SPI');
            app.anField = uieditfield(app.UIFigure,'numeric','Position',[170 440 60 22],'Value',4);

            uilabel(app.UIFigure,'Position',[250 440 150 22],'Text','U columns per SPI');
            app.bnField = uieditfield(app.UIFigure,'numeric','Position',[400 440 60 22],'Value',4);

            %% Frequency parameters
            % Start frequency
            uilabel(app.UIFigure,'Position',[30 550 100 22],'Text','Start freq / GHz');
            app.startFreqField = uieditfield(app.UIFigure,'numeric');
            app.startFreqField.Position = [20 530 100 22];
            app.startFreqField.Value = 17.7;

            % Stop frequency
            uilabel(app.UIFigure,'Position',[200 550 100 22],'Text','Stop freq / GHz');
            app.stopFreqField = uieditfield(app.UIFigure,'numeric');
            app.stopFreqField.Position = [190 530 100 22];
            app.stopFreqField.Value = 21.2;

            % Step size
            uilabel(app.UIFigure,'Position',[370 550 100 22],'Text','Freq step / GHz');
            app.stepFreqField = uieditfield(app.UIFigure,'numeric');
            app.stepFreqField.Position = [360 530 100 22];
            app.stepFreqField.Value = 0.5;

            %% SPI/U layout rules
            uilabel(app.UIFigure,'Position',[20 400 150 22],'Text','SPI layout rule');
            app.spiOrderDrop = uidropdown(app.UIFigure,...
                'Items',{'Horizontal Z','Horizontal S','Vertical Z','Vertical S'},...
                'Position',[150 400 100 22]);

            uilabel(app.UIFigure,'Position',[270 400 150 22],'Text','U layout rule');
            app.uOrderDrop = uidropdown(app.UIFigure,...
                'Items',{'Horizontal Z','Horizontal S','Vertical Z','Vertical S'},...
                'Position',[400 400 100 22]);

            %% Chip parameters
            uilabel(app.UIFigure,'Position',[20 360 150 22],'Text','Start pin A');
            app.startAField = uieditfield(app.UIFigure,'numeric','Position',[170 360 60 22],'Value',7);

            uilabel(app.UIFigure,'Position',[250 360 150 22],'Text','Start pin B');
            app.startBField = uieditfield(app.UIFigure,'numeric','Position',[400 360 60 22],'Value',3);

            %% Direction & Mirror
            uilabel(app.UIFigure,'Position',[20 320 150 22],'Text','Pin direction');
            app.directionDrop = uidropdown(app.UIFigure,...
                'Items',{'Counter-clockwise','Clockwise'},...
                'Position',[170 320 100 22]);

            uilabel(app.UIFigure,'Position',[20 290 150 22],'Text','Mirror mode');
            app.mirrorDrop = uidropdown(app.UIFigure,...
                'Items',{'Column-alternating','Row-alternating'},...
                'Position',[170 290 100 22]);

            %% HEX code input

            uilabel(app.UIFigure,'Position',[920 570 200 22],'Text','Phase-shifter HEX codes (64 rows)');

            default_hex = {
                '00';'03';'06';'0A';'0D';'11';'15';'1A';'1E';'22';
                '27';'2B';'30';'34';'38';'3B';'3E';'41';'44';'48';
                '4B';'4F';'53';'58';'5D';'62';'67';'6C';'71';'75';
                '79';'7D';
                '80';'83';'86';'8A';'8E';'92';'96';'9A';'9E';'A3';
                'A7';'AC';'B0';'B4';'B8';'BB';'BE';'C2';'C4';'C8';
                'CB';'CF';'D4';'D8';'DD';'E2';'E7';'EC';'F0';'F5';
                'F9';'FC'
                };

            app.codeHexArea = uitextarea(app.UIFigure,...
                'Position',[920 350 200 220],...
                'Value',default_hex);

            %% Buttons
            app.generateButton = uibutton(app.UIFigure,'push','Position',[20 240 150 35],'Text','Generate MAP');
            app.generateButton.ButtonPushedFcn = @(src,event)generateMap(app);              % uibutton creates a button component; app.UIFigure is the container figure; 'push' means a push button
                                                                            % ButtonPushedFcn: callback fired on click; @(src,event) is an anonymous function invoked when the button is pressed
            app.exportButton = uibutton(app.UIFigure,'push','Position',[200 240 150 35],'Text','Export CSV');   % generateMap(app) is the function that executes
            app.exportButton.ButtonPushedFcn = @(src,event)exportCSV(app);

            app.calibrateButton = uibutton(app.UIFigure,'push','Position',[380 240 150 35],'Text','Run Calibration');
            app.calibrateButton.ButtonPushedFcn = @(src,event)runCalibration(app);

            uilabel(app.UIFigure,'Position',[920 270 120 22],'Text','Calibration pass');

            app.modeDrop = uidropdown(app.UIFigure,...
                'Items',{'1','2','3','4','5','6','7','8','9','10'},...
                'Position',[920 250 80 22],...
                'Value','1');

            app.statusArea = uitextarea(app.UIFigure);
            app.statusArea.Position = [500 20 300 200];
            app.statusArea.Value = "Calibration status display area";

            %% MAP table
            app.mapTable = uitable(app.UIFigure,'Position',[20 20 460 200]);

            %% Images (unchanged)
            app.spiImage = uiimage(app.UIFigure,'Position',[520 490 160 100],'ImageSource',"spi_example.png");
            app.uImage = uiimage(app.UIFigure,'Position',[720 490 160 100],'ImageSource',"u_structure.png");
            app.pinImage = uiimage(app.UIFigure,'Position',[520 370 160 100],'ImageSource',"pin_order.png");
            app.mirrorImage = uiimage(app.UIFigure,'Position',[720 370 160 100],'ImageSource',"mirror_mode.png");
            app.orderImage = uiimage(app.UIFigure,'Position',[620 250 160 100],'ImageSource',"order_example.png");

            app.orderLabel = uilabel(app.UIFigure,'Position',[650 230 200 22],'Text',"Click an image to enlarge");

            %% Click to enlarge
            app.spiImage.ImageClickedFcn = @(src,event)showLargeImage(app,"spi_example.png");
            app.uImage.ImageClickedFcn = @(src,event)showLargeImage(app,"u_structure.png");
            app.pinImage.ImageClickedFcn = @(src,event)showLargeImage(app,"pin_order.png");
            app.mirrorImage.ImageClickedFcn = @(src,event)showLargeImage(app,"mirror_mode.png");
            app.orderImage.ImageClickedFcn = @(src,event)showLargeImage(app,"order_example.png");
            
        end


        function generateMap(app)

            % ====================== Read parameters ======================

            array_row = app.aField.Value;
            array_col = app.bField.Value;

            spi_row = app.asField.Value;
            spi_col = app.bsField.Value;

            u_per_spi_row = app.anField.Value;
            u_per_spi_col = app.bnField.Value;

            spiOrder = app.spiOrderDrop.Value;
            uOrder   = app.uOrderDrop.Value;

            start_pin_A = app.startAField.Value;
            start_pin_B = app.startBField.Value;

            direction = strcmp(app.directionDrop.Value,'Counter-clockwise') * 0 + strcmp(app.directionDrop.Value,'Clockwise') * 1;
            mirror_mode = strcmp(app.mirrorDrop.Value,'Column-alternating') * 0 + strcmp(app.mirrorDrop.Value,'Row-alternating') * 1;


            % ====================== Pin ordering ======================

            pins = 1:8;

            if direction == 0
                base_order = pins;
            else
                base_order = fliplr(pins);
            end

            idxA = find(base_order == start_pin_A);
            order_A = [base_order(idxA:end) base_order(1:idxA-1)];

            idxB = find(base_order == start_pin_B);
            order_B = [base_order(idxB:end) base_order(1:idxB-1)];


            % ====================== U RF pattern ======================

            U_A = [0 order_A(1) order_A(8) 0;
                order_A(2) 0 0 order_A(7);
                order_A(3) 0 0 order_A(6);
                0 order_A(4) order_A(5) 0];

            U_B = [0 order_B(1) order_B(8) 0;
                order_B(2) 0 0 order_B(7);
                order_B(3) 0 0 order_B(6);
                0 order_B(4) order_B(5) 0];

            U_POL = ["0" "V" "V" "0";
                "H" "0" "0" "H";
                "H" "0" "0" "H";
                "0" "V" "V" "0"];

            U_SPI = reshape(1:u_per_spi_col*u_per_spi_row,u_per_spi_row,u_per_spi_col)';
            switch uOrder
                case 'Horizontal Z'
                    U_SPI = reshape(1:u_per_spi_col*u_per_spi_row,u_per_spi_row,u_per_spi_col)';
                case 'Horizontal S'
                    U_SPI = reshape(1:u_per_spi_col*u_per_spi_row,u_per_spi_row,u_per_spi_col)';
                    for r = 2:2:u_per_spi_row
                        U_SPI(r,:) = fliplr(U_SPI(r,:));
                    end
                case 'Vertical Z'
                    U_SPI = reshape(1:u_per_spi_col*u_per_spi_row,u_per_spi_row,u_per_spi_col);
                case 'Vertical S'
                    U_SPI = reshape(1:u_per_spi_col*u_per_spi_row,u_per_spi_row,u_per_spi_col);
                    for c = 2:2:u_per_spi_col
                        U_SPI(:,c) = flipud(U_SPI(:,c));
                    end
            end
            SPI = reshape(1:spi_row*spi_col,spi_row,spi_col)';
            switch spiOrder
                case 'Horizontal Z'
                    SPI = reshape(1:spi_row*spi_col,spi_row,spi_col)';
                case 'Horizontal S'
                    SPI = reshape(1:spi_row*spi_col,spi_row,spi_col)';
                    for r = 2:2:spi_row
                        SPI(r,:) = fliplr(SPI(r,:));
                    end
                case 'Vertical Z'
                    SPI = reshape(1:spi_row*spi_col,spi_row,spi_col);
                case 'Vertical S'
                    SPI = reshape(1:spi_row*spi_col,spi_row,spi_col);
                    for c = 2:2:spi_col
                        SPI(:,c) = flipud(SPI(:,c));
                    end
            end

            spi_offset = [0 u_per_spi_col*u_per_spi_row u_per_spi_col*u_per_spi_row*2 u_per_spi_col*u_per_spi_row*3];
            Ugrid = zeros(array_row/2,array_col/2);

            for i = 1:spi_row
                for j = 1:spi_col

                    spi_num = SPI(i,j);
                    offset = spi_offset(spi_num);

                    for u_row = 1:u_per_spi_row
                        for u_col = 1:u_per_spi_col

                            row = (i-1)*u_per_spi_row + u_row;
                            col = (j-1)*u_per_spi_col + u_col;

                            Ugrid(row,col) = offset + U_SPI(u_row,u_col);

                        end
                    end

                end
            end
            disp('Generated Ugrid (8x8):');
            disp(Ugrid);

            RF = zeros(array_row*2,array_col*2);

            for ur = 1:array_row/2
                for uc = 1:array_col/2
                    r0 = (ur-1)*4 + 1;
                    c0 = (uc-1)*4 + 1;
                    if mirror_mode == 0
                        if mod(uc,2) == 1
                            RF(r0:r0+3 , c0:c0+3) = U_A;
                        else
                            RF(r0:r0+3 , c0:c0+3) = U_B;
                        end

                    else
                        if mod(ur,2) == 1
                            RF(r0:r0+3 , c0:c0+3) = U_A;
                        else
                            RF(r0:r0+3 , c0:c0+3) = U_B;
                        end

                    end

                end
            end
            Vindex = zeros(array_row*2,array_col*2);
            Hindex = zeros(array_row*2,array_col*2);

            v = 0;
            h = 0;

            for r=1:array_row*2
                for c=1:array_col*2
                    if RF(r,c)~=0
                        lr=mod(r-1,4)+1; lc=mod(c-1,4)+1;
                        if U_POL(lr,lc)=='H'
                            h=h+1; Hindex(r,c)=h;
                        else
                            v=v+1; Vindex(r,c)=v;
                        end
                    end
                end
            end
            map = zeros(array_row*array_col*2,1);
            for r = 1:array_row*2
                for c = 1:array_col*2
                    f = RF(r,c);
                    if f ~= 0
                        ur = ceil(r/4);
                        uc = ceil(c/4);
                        Uid = Ugrid(ur,uc);
                        hw = (Uid-1)*8 + f;
                        if Vindex(r,c) ~= 0
                            idx = Vindex(r,c);
                        else
                            idx = array_row*array_col + Hindex(r,c);
                        end
                        map(hw) = idx;
                    end
                end
            end


            % ====================== Output ======================

            app.mapTable.Data = map;


            % ====================== Debug plot ======================
            % 
            % figure
            % imagesc(RF)
            % colorbar
            % title('RF layout')

        end

        function exportCSV(app)
            writematrix(app.mapTable.Data, "ota_map.csv");
            uialert(app.UIFigure, "CSV exported successfully", "Success");
        end


        function showLargeImage(app, filename)
            fig = uifigure('Name','Diagram','Position',[300 200 600 600]);
            uiimage(fig, 'Position',[20 20 560 560], 'ImageSource',filename);
        end


        function runCalibration(app)
            generateMap(app);
            map = app.mapTable.Data;
            numFiles = (app.aField.Value * app.bField.Value) * 2;   % generic formula as specified

            mode = str2double(app.modeDrop.Value);

            % disp("================================")
            % disp("Running calibration pass " + mode)
            % disp("================================")
            uialert(app.UIFigure, sprintf("Running calibration pass %d", mode), "Calibration");
            code_hex = string(app.codeHexArea.Value);

            if length(code_hex) ~= 64
                uialert(app.UIFigure,"HEX code table must have 64 rows","Error");
                return
            end

            disp("Current mode = " + mode)
            disp("HEX code table loaded")

            % Continue with the original calibration algorithm below
            % (the algorithm itself is unchanged)
            if mode < 1
                uialert(app.UIFigure, 'Calibration mode must be a positive integer', 'Error');
                return;
            end
            % ========= Auto-generate frequency sweep =========
            f_start = app.startFreqField.Value;
            f_stop  = app.stopFreqField.Value;
            f_step  = app.stepFreqField.Value;

            freq_vec = f_start : f_step : f_stop;

            numFreq = length(freq_vec);

            freq_name = strings(1,numFreq);
            for i = 1:numFreq
                freq_name(i) = sprintf("%.1fGHz", freq_vec(i));
            end
            
            step_first = 5.625;

            if mode == 1
                clc;
            end
            warning('off','MATLAB:table:ModifiedAndSavedVarnames')

            %% ==================== First calibration pass =======================
            if mode == 1
                folder1 = fullfile(pwd, 'TestData1');
                phaseMatrix1 = zeros(numFiles, numFreq);

                for k = 1:numFiles
                    if k <= numFiles/2
                        folder_use = fullfile(folder1, 'Vertical');
                        idx = k;
                    else
                        folder_use = fullfile(folder1, 'Horizontal');
                        idx = k - numFiles/2;
                    end
                    filename = fullfile(folder_use, sprintf('%d.txt', idx));

                    % === Added: file-existence check (fixes the fgetl error) ===
                    fid = fopen(filename, 'r');
                    if fid == -1
                        errMsg = sprintf('Unable to open file!\nPath: %s\n\nCurrent working directory: %s\n\nPlease verify:\n1. Folders "TestData1\\Vertical" and "TestData1\\Horizontal" are in the same directory as the app\n2. They contain 1.txt through %d.txt\n3. The files are not in use by another program', filename, pwd, numFiles);
                        uialert(app.UIFigure, errMsg, 'File Read Failed');
                        return;
                    end

                    for i = 1:numFreq
                        line = fgetl(fid);
                        tokens = regexp(line, 'Frequency:(\d+)\s+Amplitude:[-\d.]+\s+Phase:([-\d.]+)', 'tokens');
                        phaseMatrix1(k,i) = str2double(tokens{1}{2});
                    end
                    fclose(fid);
                end

                phaseR = zeros(numFiles, numFreq);
                benchmark = (app.aField.Value * app.bField.Value) * (0.5 + app.aField.Value/2) / (app.aField.Value * 2);  % formula as provided
                for f = 1:numFreq
                    phase = phaseMatrix1(:,f);
                    for idx = 1:numFiles/2
                        phaseR(idx,f) = phase(idx) - phase(benchmark);
                        phaseR(idx+numFiles/2,f) = phase(idx+numFiles/2) - phase(benchmark + app.aField.Value);
                    end
                end
                phase_cal = -phaseR;

                for f = 1:numFreq
                    phase_this = phase_cal(:, f);
                    phase_mapped = phase_this(map);
                    p_q = round(phase_mapped / step_first) * step_first;
                    p_idx = mod(p_q / 5.625, 64) + 1;
                    code_all(:, f) = code_hex(p_idx);
                end

                filename = 'calibration_values_1.xlsx';
                for f = 1:numFreq
                    T = table(code_all(:, f), 'VariableNames', {'CalibrationCode'});
                    writetable(T, filename, 'Sheet', freq_name(f));
                end

                for f = 1:numFreq
                    fname = sprintf("fpga_1_%s.txt", freq_name(f));
                    generate_fpga_code(app, code_all(:, f), fname);   % fix: pass app (resolves second warning)
                end
                disp("First calibration pass complete")
            end

            %% ==================== Second and subsequent calibration passes ====================
            if mode >= 2
                folder = fullfile(pwd, sprintf('TestData%d', mode));
                phaseMatrix = zeros(numFiles, numFreq);

                for k = 1:numFiles
                    if k <= numFiles/2
                        folder_use = fullfile(folder, 'Vertical');
                        idx = k;
                    else
                        folder_use = fullfile(folder, 'Horizontal');
                        idx = k - numFiles/2;
                    end
                    filename = fullfile(folder_use, sprintf('%d.txt', idx));

                    % === Added: file-existence check (prevents fgetl crash) ===
                    fid = fopen(filename, 'r');
                    if fid == -1
                        errMsg = sprintf('Unable to open file!\nPath: %s\n\nCurrent working directory: %s\n\nPlease ensure "TestData%d" is in the same directory as the app and contains Vertical/Horizontal subfolders with 1.txt through %d.txt', filename, pwd, mode, numFiles);
                        uialert(app.UIFigure, errMsg, 'File Read Failed');
                        return;
                    end

                    for i = 1:numFreq
                        line = fgetl(fid);
                        tokens = regexp(line, 'Frequency:(\d+)\s+Amplitude:[-\d.]+\s+Phase:([-\d.]+)', 'tokens');
                        phaseMatrix(k,i) = str2double(tokens{1}{2});
                    end
                    fclose(fid);
                end

                %% Circular-statistics flatness check
                is_flat = false(1, numFreq);
                circ_std_all = zeros(1, numFreq);

                for f = 1:numFreq
                    phases = phaseMatrix(:, f);
                    theta = deg2rad(phases);
                    R = abs(mean(exp(1j*theta)));
                    circ_std = rad2deg(sqrt(-2*log(R)));

                    circ_std_all(f) = circ_std;

                    if circ_std < 3
                        is_flat(f) = true;
                    end
                end

                %% ===== Build UI status display =====
                status_lines = strings(numFreq+2,1);
                status_lines(1) = "=== Flatness check (circular std < 3 deg) ===";

                for f = 1:numFreq
                    if is_flat(f)
                        status_lines(f+1) = sprintf("%s   OK - flat (%.2f deg)", freq_name(f), circ_std_all(f));
                    else
                        status_lines(f+1) = sprintf("%s   NOT flat (%.2f deg)", freq_name(f), circ_std_all(f));
                    end
                end

                flat_count = sum(is_flat);
                status_lines(end) = "Flat frequency points: " + flat_count + " / " + numFreq;

                app.statusArea.Value = status_lines;

                %% ===== Check if all frequencies are flat =====
                if all(is_flat)
                    app.statusArea.Value = [
                        status_lines
                        "All frequency points are calibrated flat!"
                        ];

                    uialert(app.UIFigure,'All frequency points are calibrated flat!','Complete');
                    return;
                end

                %% Read previous round's code table (unchanged)
                prev_excel = sprintf('calibration_values_%d.xlsx', mode-1);
                code_prev = zeros(numFiles, numFreq);
                for f = 1:numFreq
                    T = readtable(prev_excel, 'Sheet', freq_name(f));
                    code_first = string(T{:,1});
                    for i = 1:numFiles
                        code_prev(i,f) = find(code_hex == code_first(i)) - 1;
                    end
                end

                if mode == 2
                    step_cal = 11.25;
                else
                    step_cal = 5.625;
                end
                code_new = code_prev;

                %% Per-frequency calibration
                for f = 1:numFreq
                    if is_flat(f)
                        continue;
                    end

                    %% V polarization
                    phaseV = phaseMatrix(1:numFiles/2, f);
                    half = step_cal/2;
                    max_countV = -1; targetV = phaseV(1);
                    for i = 1:numFiles/2
                        diff = abs(mod(phaseV - phaseV(i) + 180,360)-180);
                        count = sum(diff <= half);
                        if count > max_countV
                            max_countV = count; targetV = phaseV(i);
                        end
                    end
                    diff_all = abs(mod(phaseV-targetV+180,360)-180);
                    mask = diff_all > half;
                    delta = targetV - phaseV;
                    delta(~mask) = 0;
                    delta = mod(delta+180,360)-180;
                    delta_codeV = round(delta/5.625);

                    %% H polarization
                    phaseH = phaseMatrix(numFiles/2 + 1 : numFiles, f);
                    max_countH = -1; targetH = phaseH(1);
                    for i = 1:numFiles/2
                        diff = abs(mod(phaseH - phaseH(i) + 180,360)-180);
                        count = sum(diff <= half);
                        if count > max_countH
                            max_countH = count; targetH = phaseH(i);
                        end
                    end
                    diff_all = abs(mod(phaseH-targetH+180,360)-180);
                    mask = diff_all > half;
                    delta = targetH - phaseH;
                    delta(~mask) = 0;
                    delta = mod(delta+180,360)-180;
                    delta_codeH = round(delta/5.625);

                    %% Merge (fixes the previously missing ,f index)
                    delta_code = zeros(numFiles,1);
                    delta_code(1:numFiles/2) = delta_codeV;
                    delta_code(numFiles/2 + 1 : numFiles) = delta_codeH;

                    for idx = 1:numFiles
                        hpos = map(idx);
                        code_new(hpos,f) = mod(code_prev(hpos,f) + delta_code(idx),64);
                    end
                end

                code_final = code_hex(code_new+1);

                excel_name = sprintf('calibration_values_%d.xlsx',mode);
                for f = 1:numFreq
                    writetable(table(code_final(:,f)), excel_name, 'Sheet', freq_name(f));
                end

                for f = 1:numFreq
                    fname = sprintf("fpga_%d_%s.txt", mode, freq_name(f));
                    generate_fpga_code(app, code_final(:,f), fname);   % fix: pass app
                end
                disp("Calibration pass " + mode + " complete")
            end
        end


        function generate_fpga_code(app, code, filename)   % key fix: added app parameter (App Designer requires methods to take app)
            % app is unused, but App Designer requires methods to accept it
            fid = fopen(filename, 'w');
            fprintf(fid, "always@(posedge i_clk,posedge i_rst)\n");
            fprintf(fid, "begin\n");
            fprintf(fid, "\tif(i_rst)\n");
            fprintf(fid, "\t\tbegin\n");
            fprintf(fid, "\t\t\treg8 <= 'd0;\n");
            fprintf(fid, "\t\t\trega <= 'd0;\n");
            fprintf(fid, "\t\tend\n");
            fprintf(fid, "\telse\n");
            fprintf(fid, "\t\tbegin\n");

            for ant = 0:3
                idx = ant*8+1;
                P = code(idx:idx+7);
                reg8 = sprintf("%s%s_%s%s",P(4),P(3),P(2),P(1));
                rega = sprintf("%s%s_%s%s",P(8),P(7),P(6),P(5));

                if ant==0
                    fprintf(fid,"\t\t\tif(antenna==%d)\n",ant);
                else
                    fprintf(fid,"\t\t\telse if(antenna==%d)\n",ant);
                end
                fprintf(fid,"\t\t\t\tbegin\n");
                fprintf(fid,"\t\t\t\t\treg8 <= {16'h0008, 32'h%s};\n",reg8);
                fprintf(fid,"\t\t\t\t\trega <= {16'h000a, 32'h%s};\n",rega);
                fprintf(fid,"\t\t\t\tend\n");
            end

            fprintf(fid,"\t\t\telse\n");
            fprintf(fid,"\t\t\t\tbegin\n");
            fprintf(fid,"\t\t\t\t\treg8 <= reg8;\n");
            fprintf(fid,"\t\t\t\t\trega <= rega;\n");
            fprintf(fid,"\t\t\t\tend\n");
            fprintf(fid,"\t\tend\n");
            fprintf(fid,"end\n");
            fclose(fid);
        end

    end


    methods (Access = public)
        function app = OtaMapCalibrationApp
            startup(app);
        end
    end

end
