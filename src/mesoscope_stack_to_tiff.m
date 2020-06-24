function meso_stack = mesoscope_stack_to_tiff(in_filename_base)
%% convert mesoscopic z-stacks to stitched multiplane TIFF, assuming one channel in file
infn = in_filename_base;
chan_ix = 1;

%%
[raw, myinfo] = sbxread_all(infn);

%%
overlap = 15;
frame_rows = myinfo.sz(1);
frame_cols = myinfo.sz(2);
tiles_hor_n = numel(unique(myinfo.mesoscope.galvo_b));
tiles_vrt_n = numel(unique(myinfo.mesoscope.galvo_a));
tiles_n = tiles_hor_n * tiles_vrt_n;
steps_n = size(myinfo.config.knobby.schedule, 1) + 1;
iter_per_step = myinfo.config.knobby.schedule(1,5) / tiles_n;

%% generate loopup table for mapping tile hor and vrt ix to frame no
% frames are acquired in snake line: first col down, second col up
frame_ix_lut = reshape(1 : tiles_n, [tiles_vrt_n tiles_hor_n]);
for colix = 2 : 2 : tiles_hor_n
    frame_ix_lut(:, colix) =  frame_ix_lut(end:-1:1, colix);
end

%%
meso_stack = uint16(zeros(tiles_vrt_n * frame_rows - (overlap * (tiles_vrt_n - 1)), ...
    tiles_hor_n * frame_cols  - (overlap * (tiles_hor_n - 1)), steps_n, iter_per_step));

for step_ix = 1 : steps_n
    for tile_hor_ix = 1 : tiles_hor_n
        for tile_vrt_ix = 1 : tiles_vrt_n
            for iter_ix = 1 : iter_per_step
                frame_ix = frame_ix_lut(tile_vrt_ix, tile_hor_ix);
                ol = floor(overlap/2);
                h0 = (frame_cols - 2*ol) * (tile_hor_ix - 1) + 1;
                v0 = (frame_rows - 2*ol) * (tile_vrt_ix - 1) + 1;
                raw_frame_ix = (iter_ix - 1) * tiles_n + frame_ix + tiles_n * iter_per_step * (step_ix - 1);
                if raw_frame_ix > myinfo.max_idx  %% for some reason, scanbox always delivers one frame less than requested in the gui.
                    continue
                end
                meso_stack(v0 : (v0 + frame_rows - 1 - 2*ol), h0 : (h0+frame_cols-1 - 2*ol), step_ix, iter_ix) = ...
                    squeeze(raw(chan_ix, ol+1:end-ol, ol+1:end-ol, raw_frame_ix));
            end
         end
    end
end

%% save to tif, averaging over iterations, and flipping sequence of z planes (because Tobias likes to start stacks at greatest depth)
is_first = true;
for z = size(meso_stack, 3) : -1 : 1
    if is_first
        imwrite(uint16(squeeze(mean(meso_stack(:,:,z,:), 4))),[infn '.tif'],'tif');
        is_first = false;
    else
        imwrite(uint16(squeeze(mean(meso_stack(:,:,z,:), 4))),[infn '.tif'],'tif','writemode','append');
    end
end

%%
%figure;
%imagesc(meso_stack(:,:,4));
%axis image;
%colorbar;
end
