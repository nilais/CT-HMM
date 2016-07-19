function CTHMM_learn_vis_Q_mat(top_out_folder)

global data_setting;
global is_draw_learn_Q_mat;

if (is_draw_learn_Q_mat == 1)
    if (data_setting.dim == 2)    
        is_vis_nij = 1;
        vis_threshold = 0.1;
        is_draw_text = 1.0;
        CTHMM_vis_2D_Q_mat(top_out_folder, is_vis_nij, vis_threshold, is_draw_text);    
        is_vis_nij = 0;
        vis_threshold = 0.1;
        is_draw_text = 1.0;
        CTHMM_vis_2D_Q_mat(top_out_folder, is_vis_nij, vis_threshold, is_draw_text);    
    elseif (data_setting.dim == 3)    
        is_vis_nij = 1;
        vis_threshold = 0.1;
        CTHMM_vis_3D_Q_mat(top_out_folder, is_vis_nij, vis_threshold);
        is_vis_nij = 0;
        vis_threshold = 0.1;
        CTHMM_vis_3D_Q_mat(top_out_folder, is_vis_nij, vis_threshold);        
    end
end


