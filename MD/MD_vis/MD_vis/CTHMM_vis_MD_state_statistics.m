function CTHMM_vis_MD_state_statistics()

global data_setting;
dim = data_setting.dim;

if (dim == 2) 
    CTHMM_vis_2D_state_statistics();
elseif (dim == 3)
    CTHMM_vis_3D_state_statistics(1);
end


            

