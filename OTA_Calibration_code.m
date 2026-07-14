clear;

%% =================
mode = 1;
%% =================
% 1 = first calibration
% 2 = second calibration
% 3 = third calibration
% 4 = forth calibration
% ...
if mode == 1
    clc;
end
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

numFiles = 512;
numFreq  = 4;

step_first = 5.625;

% Lookup table mapping 6-bit quantized phase states (0deg-360deg) to the hexadecimal control codes used by the phase shifter.
code_hex = [
"00";"03";"06";"0A";"0D";"11";"15";"1A";"1E";"22";
"27";"2B";"30";"34";"38";"3B";"3E";"41";"44";"48";
"4B";"4F";"53";"58";"5D";"62";"67";"6C";"71";"75";
"79";"7D";
"80";"83";"86";"8A";"8E";"92";"96";"9A";"9E";"A3";
"A7";"AC";"B0";"B4";"B8";"BB";"BE";"C2";"C4";"C8";
"CB";"CF";"D4";"D8";"DD";"E2";"E7";"EC";"F0";"F5";
"F9";"FC"
];

% Mapping from the antenna measurement sequence in the anechoic chamber to the corresponding FPGA channel indices.
map = [
273 17 18 274 258 2 1 257 260 4 3 259 275 19 20 276 277 21 22 278 262 6 5 261 264 8 7 263 279 23 24 280 305 49 50 306 290 34 33 289 292 36 35 291 307 51 52 308 309 53 54 310 294 38 37 293 296 40 39 295 311 55 56 312 337 81 82 338 322 66 65 321 324 68 67 323 339 83 84 340 341 85 86 342 326 70 69 325
328 72 71 327 343 87 88 344 369 113 114 370 354 98 97 353 356 100 99 355 371 115 116 372 373 117 118 374 358 102 101 357 360 104 103 359 375 119 120 376 281 25 26 282 266 10 9 265 268 12 11 267 283 27 28 284 285 29 30 286 270 14 13 269 272 16 15 271 287 31 32 288 313 57 58 314 298 42 41 297
300 44 43 299 315 59 60 316 317 61 62 318 302 46 45 301 304 48 47 303 319 63 64 320 345 89 90 346 330 74 73 329 332 76 75 331 347 91 92 348 349 93 94 350 334 78 77 333 336 80 79 335 351 95 96 352 377 121 122 378 362 106 105 361 364 108 107 363 379 123 124 380 381 125 126 382 366 110 109 365
368 112 111 367 383 127 128 384 401 145 146 402 386 130 129 385 388 132 131 387 403 147 148 404 405 149 150 406 390 134 133 389 392 136 135 391 407 151 152 408 433 177 178 434 418 162 161 417 420 164 163 419 435 179 180 436 437 181 182 438 422 166 165 421 424 168 167 423 439 183 184 440 465 209 210 466 450 194 193 449 452 196 195 451 467 211 212 468
469 213 214 470 454 198 197 453 456 200 199 455 471 215 216 472 497 241 242 498 482 226 225 481 484 228 227 483 499 243 244 500 501 245 246 502 486 230 229 485 488 232 231 487 503 247 248 504 409 153 154 410 394 138 137 393 396 140 139 395 411 155 156 412 413 157 158 414 398 142 141 397 400 144 143 399 415 159 160 416
441 185 186 442 426 170 169 425 428 172 171 427 443 187 188 444 445 189 190 446 430 174 173 429 432 176 175 431 447 191 192 448 473 217 218 474 458 202 201 457 460 204 203 459 475 219 220 476 477 221 222 478 462 206 205 461 464 208 207 463 479 223 224 480 505 249 250 506 490 234 233 489 492 236 235 491 507 251 252 508
509 253 254 510 494 238 237 493 496 240 239 495 511 255 256 512
];
map = map(:);

freq_name = ["28.5GHz","29.0GHz","29.5GHz","30.0GHz"];

%% =================================================
% =============== first calibration ================
% =================================================

if mode == 1

phaseMatrix1 = zeros(numFiles,numFreq);

%% ========================================================
folder1 = 'C:\Users\PC\Desktop\matlab\Newfolder\testdata1';
%% ========================================================
folder_v = fullfile(folder1,'vertical');
folder_h = fullfile(folder1,'horizontal');

for k = 1:512
    
    if k<=256
        folder_use = folder_v;
        idx = k;
    else
        folder_use = folder_h;
        idx = k-256;
    end
    
    filename = fullfile(folder_use,sprintf('%d.txt',idx));
    fid = fopen(filename,'r');
    
    for i = 1:numFreq
        line = fgetl(fid);
        tokens = regexp(line,'Frequency:(\d+)\s+Amplitude:[-\d.]+\s+Phase:([-\d.]+)','tokens');   
        phaseMatrix1(k,i) = str2double(tokens{1}{2});
    end
    
    fclose(fid);
end

phaseR = zeros(512,numFreq);

for f = 1:numFreq       % reset
    phase = phaseMatrix1(:,f);
    for idx = 1:256
        phaseR(idx,f) = phase(idx) - phase(120);
        phaseR(idx+256,f) = phase(idx+256) - phase(376);
    end
end
phase_cal = -phaseR;   % 32 × numFreq

for f = 1:numFreq
    phase_this = phase_cal(:, f);
    phase_mapped = phase_this(map);
    p_q = round(phase_mapped / step_first) * step_first;
    p_idx = mod(p_q / 5.625, 64) + 1;
    code_all(:, f) = code_hex(p_idx);
end

% output to Excel（each frequency has its own sheet）
filename = 'cali_value_256_1.xlsx';
for f = 1:numFreq
    T = table(code_all(:, f), 'VariableNames', {'cali_code'});
    writetable(T, filename, 'Sheet', freq_name(f), 'WriteVariableNames', true);
end

% generate FPGA file
for f = 1:numFreq
    fname = sprintf("fpga256_1_%s.txt", freq_name(f));
    generate_fpga_code(code_all(:, f), fname);
end

disp("first calibration accomplished")

end

%% =================================================
%% ==== second and thereafter calibration ==========
%% =================================================

if mode >= 2

phaseMatrix = zeros(numFiles,numFreq);

%% ============================================================================
folder = sprintf('C:\\Users\\PC\\Desktop\\matlab\\Newfolder\\testdatab\\testdata%d',mode);
%% ============================================================================
folder_v = fullfile(folder,'vertical');
folder_h = fullfile(folder,'horizontal');

for k = 1:512
    
    if k<=256
        folder_use = folder_v;
        idx = k;
    else
        folder_use = folder_h;
        idx = k-256;
    end
    
    filename = fullfile(folder_use,sprintf('%d.txt',idx));
    fid = fopen(filename,'r');
    
    for i = 1:numFreq
        
        line = fgetl(fid);
        tokens = regexp(line,'Frequency:(\d+)\s+Amplitude:[-\d.]+\s+Phase:([-\d.]+)','tokens');
        phaseMatrix(k,i) = str2double(tokens{1}{2});
        
    end
    
    fclose(fid);
end

%% ==================== Circular Statistics Flatness Check ====================

is_flat = false(1, numFreq);

fprintf('\n=== Flatness Check（circular std < 3°） ===\n');

for f = 1:numFreq
    
    phases = phaseMatrix(:, f);
    
    % Convert to radians
    theta = deg2rad(phases);
    
    % circular mean vector
    R = abs(mean(exp(1j*theta)));
    
    % circular std
    circ_std = rad2deg(sqrt(-2*log(R)));
    
    if circ_std < 3
        
        is_flat(f) = true;
        fprintf('Phase %s calibration completed！(circular std = %.2f°)\n', freq_name(f), circ_std);
        
    else
        
        fprintf('Frequency %s calibration required (circular std = %.2f°)\n', freq_name(f), circ_std);
        
    end
    
end

fprintf('Number of calibrated frequency points：%d / %d\n\n', sum(is_flat), numFreq);

%% Terminate if all frequency points are calibrated

if all(is_flat)
    
    disp('【All frequency points have been calibrated.】Program terminated！');
    return;
    
end

%% ==================== load the codebook from the previous iteration ====================

prev_excel = sprintf('calibration_value_256_%d.xlsx',mode-1);

code_prev = zeros(512,numFreq);

for f = 1:numFreq
    
    T = readtable(prev_excel,'Sheet',freq_name(f));
    
    code_first = string(T{:,1});
    
    for i=1:512
        
        code_prev(i,f) = find(code_hex == code_first(i)) - 1;
        
    end
    
end

%% ==================== Calibration step size ====================

if mode == 2
    step_cal = 11.25;
else
    step_cal = 5.625;
end

code_new = code_prev;

%% ==================== Calibration for each frequency point ====================

for f = 1:numFreq
    
    if is_flat(f)
        
        fprintf('Frequency %s Calibration completed，Skipping this frequency point\n', freq_name(f));
        continue;
        
    end
    
    %% ==================== V Polarization ====================
    
    phaseV = phaseMatrix(1:256, f);
    
    half = step_cal/2;
    
    max_countV = -1;
    targetV = phaseV(1);
    
    for i = 1:256
        
        diff = abs(mod(phaseV - phaseV(i) + 180,360)-180);
        count = sum(diff <= half);
        
        if count > max_countV
            
            max_countV = count;
            targetV = phaseV(i);
            
        end
        
    end
    
    diff_all = abs(mod(phaseV-targetV+180,360)-180);
    
    mask = diff_all > half;
    
    %% Phase correction direction
    
    delta = targetV - phaseV;
    
    delta(~mask) = 0;
    
    delta = mod(delta+180,360)-180;
    
    delta_codeV = round(delta/5.625);
    
    
    %% ==================== H Polarization ====================
    
    phaseH = phaseMatrix(257:512, f);
    
    max_countH = -1;
    targetH = phaseH(1);
    
    for i = 1:256
        
        diff = abs(mod(phaseH - phaseH(i) + 180,360)-180);
        count = sum(diff <= half);
        
        if count > max_countH
            
            max_countH = count;
            targetH = phaseH(i);
            
        end
        
    end
    
    diff_all = abs(mod(phaseH-targetH+180,360)-180);
    
    mask = diff_all > half;
    
    %% Phase correction direction
    
    delta = targetH - phaseH;
    
    delta(~mask) = 0;
    
    delta = mod(delta+180,360)-180;
    
    delta_codeH = round(delta/5.625);
    
    
    %% ==================== Merge phase correction ====================
    
    delta_code = zeros(512,1);
    
    delta_code(1:256) = delta_codeV;
    delta_code(257:512) = delta_codeH;
    
    for idx = 1:512
        
        hpos = map(idx);
        
        code_new(hpos,f) = mod(code_prev(hpos,f) + delta_code(idx),64);
        
    end
    
end

%% ==================== Export results ====================

code_final = code_hex(code_new+1);

excel_name = sprintf('calibration_value_256_%d.xlsx',mode);

for f = 1:numFreq
    
    T = table(code_final(:,f));
    
    writetable(T,excel_name,'Sheet',freq_name(f))
    
end

for f = 1:numFreq
    
    fname = sprintf("fpga256_%d_%s.txt",mode,freq_name(f));
    
    generate_fpga_code(code_final(:,f),fname)
    
end

disp("Calibration iteration "+mode+" completed")

end

%% =================================================
%% FPGA Code Generation Function
%% =================================================

function generate_fpga_code(code,filename)

fid = fopen(filename,'w');

fprintf(fid,"always@(posedge i_clk,negedge i_rst)\n");
fprintf(fid,"\tbegin\n");
fprintf(fid,"\t\tif(!i_rst)begin\n");
fprintf(fid,"\t\t\ti <= 'd0;\n");
fprintf(fid,"\t\t\tj <= 'd0;\n");
fprintf(fid,"\t\t\treg8 <= 'd0;\n");
fprintf(fid,"\t\t\trega <= 'd0;end\n");
fprintf(fid,"\t\telse\n");

group = 0;

for i = 0:3
    
    if i==0
        fprintf(fid,"\t\t\tif(i==%d)\n",i);
    else
        fprintf(fid,"\t\t\telse if(i==%d)\n",i);
    end
    
    fprintf(fid,"\t\t\t\tbegin\n");
    
    for ant = 0:15
        
        idx = group*8 + 1;
        
        P = code(idx:idx+7);
        
        reg8 = sprintf("%s%s_%s%s",P(4),P(3),P(2),P(1));
        rega = sprintf("%s%s_%s%s",P(8),P(7),P(6),P(5));
        
        if ant==0
            fprintf(fid,"\t\t\t\t\tif(antenna==%d)begin\n",ant);
        else
            fprintf(fid,"\t\t\t\t\telse if(antenna==%d)\n",ant);
            fprintf(fid,"\t\t\t\t\tbegin\n");
        end
        
        fprintf(fid,"\t\t\t\t\t\treg8 <= {16'h0008, 32'h%s};\n",reg8);
        fprintf(fid,"\t\t\t\t\t\trega <= {16'h000a, 32'h%s};\n",rega);
        fprintf(fid,"\t\t\t\t\tend\n");
        
        group = group + 1;
        
    end
    
    fprintf(fid,"\t\t\t\t\telse begin\n");
    fprintf(fid,"\t\t\t\t\t\treg8 <= reg8;\n");
    fprintf(fid,"\t\t\t\t\t\trega <= rega;\n");
    fprintf(fid,"\t\t\t\t\tend\n");
    
    fprintf(fid,"\t\t\t\tend\n");
    
end

fprintf(fid,"\t\t\telse begin\n");
fprintf(fid,"\t\t\t\treg8 <= reg8;\n");
fprintf(fid,"\t\t\t\trega <= rega;\n");
fprintf(fid,"\t\t\tend\n");

fprintf(fid,"\tend\n");

fclose(fid);

disp("FPGA code generated: " + filename)

end
