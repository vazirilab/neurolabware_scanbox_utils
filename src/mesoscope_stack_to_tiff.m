function meso_stack = mesoscope_stack_to_tiff(in_filename_base)
%% convert mesoscopic z-stacks to stitched multiplane TIFF, assuming one channel in file
infn = in_filename_base;
chan_ix = 1;

%%
[raw, myinfo] = sbxread_all(infn);

%%
frame_rows = myinfo.sz(1);
frame_cols = myinfo.sz(2);
tiles_hor_n = numel(unique(myinfo.mesoscope.galvo_b));
tiles_vrt_n = numel(unique(myinfo.mesoscope.galvo_a));
tiles_n = tiles_hor_n * tiles_vrt_n;
steps_n = size(myinfo.config.knobby.schedule, 1);

%% generate loopup table for mapping tile hor and vrt ix to frame no
% frames are acquired in snake line: first col down, second col up
frame_ix_lut = reshape(1 : tiles_n, [tiles_vrt_n tiles_hor_n]);
for colix = 2 : 2 : tiles_hor_n
    frame_ix_lut(:, colix) =  frame_ix_lut(end:-1:1, colix);
end

%%
meso_stack = uint16(zeros(tiles_vrt_n * frame_rows, tiles_hor_n * frame_cols, steps_n));

for step_ix = 1 : steps_n
    for tile_hor_ix = 1 : tiles_hor_n
        for tile_vrt_ix = 1 : tiles_vrt_n
            frame_ix = frame_ix_lut(tile_vrt_ix, tile_hor_ix);
            h0 = frame_cols * (tile_hor_ix - 1) + 1;
            v0 = frame_rows * (tile_vrt_ix - 1) + 1;
            meso_stack(v0 : v0+frame_rows-1, h0 : h0+frame_cols-1, step_ix) = squeeze(raw(chan_ix, :, :, frame_ix + tiles_n * (step_ix - 1)));
        end
    end
end

%% save to tif
for z = 1 : size(meso_stack, 3)
    if(z==1)
        imwrite(meso_stack(:,:,z),[infn '.tif'],'tif');
    else
        imwrite(meso_stack(:,:,z),[infn '.tif'],'tif','writemode','append');
    end
end

%%
%figure;
%imagesc(meso_stack(:,:,4));
%axis image;
%colorbar;
end