  "  ?   k820309    ?          18.0        íIj^                                                                                                          
       letkf_tools.f90 LETKF_TOOLS              DAS_LETKF                                                     
                @                                         
                                                           
                @                                         
                            @                              
                                                           
                                                           
                @          @                              
       RP                @  @               A           	     'ð                   #NOBS 
   #ELM    #LON    #LAT    #LEV    #DAT    #ERR    #TYP    #DIF    #META    #IDXTMP    #ERRTMP                                               
                                                                                                0                                                                                       &                                                                                                P                 
            &                                                                                                                 
            &                                                                                                à                 
            &                                                                                                (                
            &                                                                                                p                
            &                                                                                                 ¸                            &                                                                                                              	   
            &                                                                                                 H             
  
  p          p            p                                                                             
                  ×yön¸ÈþÆ                                                              `                            &                                                                                                ¨                
            &                                                          @  @               A                '                   #NOBS    #NOBS_IN_KEY    #SET    #IDX    #KEY    #VAL    #TMP    #ENSTMP    #ENSVAL    #QC     #RI !   #RJ "                                                                                                                                              0                                                                                                                                              0                                                                                       &                                                                                                 P                             &                                                                                                                              &                                                                                                à                 
            &                                                                                                (                
            &                                                                                                p                
            &                   &                                                                                                Ð             	   
            &                   &                                                                                                  0             
               &                                                                                    !            x                
            &                                                                                    "            À                
            &                                                          @  @               @           #     '                   #NGRD_I $   #NGRD_J %   #GRDSPC_I &   #GRDSPC_J '   #NGRDSCH_I (   #NGRDSCH_J )   #NGRDEXT_I *   #NGRDEXT_J +   #N ,   #AC -   #TOT .   #N_EXT /   #AC_EXT 0   #TOT_EXT 1   #TOT_SUB 2   #TOT_G 3   #NEXT 4                                               $                                                               %                                                             &               
                                              '               
                                               (                                                              )                                                              *                                                               +     $                                                       ,            (              	               &                   &                   &                                                                                     -                           
               &                   &                   &                                                                                     .                                        &                                                                                     /            `                            &                   &                                                                                     0            À                            &                   &                                                                                       1                                                              2            $                  p          p            p                                                                      3            ,                  p          p            p                                                                    4            8                            &                   &                                                                                        5                                                         #         @                                   6                    #GUES3D 7   #GUES2D ;   #ANAL3D <   #ANAL2D =            
D @                              7                    
           p        5 r 8   p        5 r 9   p        5 r :   p          5 r :     5 r 9     5 r 8     p            5 r :     5 r 9     5 r 8     p                                   
D @                              ;                    
         p        5 r 8   p        5 r :   p          5 r :     5 r 8     p             5 r :     5 r 8     p                                    D                                <                    
           p        5 r 8   p        5 r 9   p        5 r :   p          5 r :     5 r 9     5 r 8     p            5 r :     5 r 9     5 r 8     p                                   D                                =                    
         p        5 r 8   p        5 r :   p          5 r :     5 r 8     p             5 r :     5 r 8     p                                      @@                              8                        @@                              :                         @                              9                   $      fn#fn !   Ä      b   uapp(LETKF_TOOLS    Þ   @   J  COMMON      @   j  COMMON_NML    ^  @   J  COMMON_MPI      @   J  COMMON_SCALE !   Þ  @   j  COMMON_MPI_SCALE      @   J  COMMON_LETKF    ^  @   j  LETKF_OBS       C   J  SCALE_PRECISION *   á  Ä      OBS_INFO+COMMON_OBS_SCALE /   ¥  ¥   a   OBS_INFO%NOBS+COMMON_OBS_SCALE .   J     a   OBS_INFO%ELM+COMMON_OBS_SCALE .   Þ     a   OBS_INFO%LON+COMMON_OBS_SCALE .   r     a   OBS_INFO%LAT+COMMON_OBS_SCALE .        a   OBS_INFO%LEV+COMMON_OBS_SCALE .        a   OBS_INFO%DAT+COMMON_OBS_SCALE .   .     a   OBS_INFO%ERR+COMMON_OBS_SCALE .   Â     a   OBS_INFO%TYP+COMMON_OBS_SCALE .   V     a   OBS_INFO%DIF+COMMON_OBS_SCALE /   ê  ø   a   OBS_INFO%META+COMMON_OBS_SCALE 1   â	     a   OBS_INFO%IDXTMP+COMMON_OBS_SCALE 1   v
     a   OBS_INFO%ERRTMP+COMMON_OBS_SCALE .   
  È      OBS_DA_VALUE+COMMON_OBS_SCALE 3   Ò  ¥   a   OBS_DA_VALUE%NOBS+COMMON_OBS_SCALE :   w  ¥   a   OBS_DA_VALUE%NOBS_IN_KEY+COMMON_OBS_SCALE 2        a   OBS_DA_VALUE%SET+COMMON_OBS_SCALE 2   °     a   OBS_DA_VALUE%IDX+COMMON_OBS_SCALE 2   D     a   OBS_DA_VALUE%KEY+COMMON_OBS_SCALE 2   Ø     a   OBS_DA_VALUE%VAL+COMMON_OBS_SCALE 2   l     a   OBS_DA_VALUE%TMP+COMMON_OBS_SCALE 5      ¬   a   OBS_DA_VALUE%ENSTMP+COMMON_OBS_SCALE 5   ¬  ¬   a   OBS_DA_VALUE%ENSVAL+COMMON_OBS_SCALE 1   X     a   OBS_DA_VALUE%QC+COMMON_OBS_SCALE 1   ì     a   OBS_DA_VALUE%RI+COMMON_OBS_SCALE 1        a   OBS_DA_VALUE%RJ+COMMON_OBS_SCALE (          OBS_GRID_TYPE+LETKF_OBS /   2  H   a   OBS_GRID_TYPE%NGRD_I+LETKF_OBS /   z  H   a   OBS_GRID_TYPE%NGRD_J+LETKF_OBS 1   Â  H   a   OBS_GRID_TYPE%GRDSPC_I+LETKF_OBS 1   
  H   a   OBS_GRID_TYPE%GRDSPC_J+LETKF_OBS 2   R  H   a   OBS_GRID_TYPE%NGRDSCH_I+LETKF_OBS 2     H   a   OBS_GRID_TYPE%NGRDSCH_J+LETKF_OBS 2   â  H   a   OBS_GRID_TYPE%NGRDEXT_I+LETKF_OBS 2   *  H   a   OBS_GRID_TYPE%NGRDEXT_J+LETKF_OBS *   r  Ä   a   OBS_GRID_TYPE%N+LETKF_OBS +   6  Ä   a   OBS_GRID_TYPE%AC+LETKF_OBS ,   ú     a   OBS_GRID_TYPE%TOT+LETKF_OBS .     ¬   a   OBS_GRID_TYPE%N_EXT+LETKF_OBS /   :  ¬   a   OBS_GRID_TYPE%AC_EXT+LETKF_OBS 0   æ  H   a   OBS_GRID_TYPE%TOT_EXT+LETKF_OBS 0   .     a   OBS_GRID_TYPE%TOT_SUB+LETKF_OBS .   Ê     a   OBS_GRID_TYPE%TOT_G+LETKF_OBS -   f  ¬   a   OBS_GRID_TYPE%NEXT+LETKF_OBS #     p       RP+SCALE_PRECISION      x       DAS_LETKF !   ú  T  a   DAS_LETKF%GUES3D !   N    a   DAS_LETKF%GUES2D !   b  T  a   DAS_LETKF%ANAL3D !   ¶     a   DAS_LETKF%ANAL2D &   Ê!  @      NENS+COMMON_MPI_SCALE &   
"  @      NIJ1+COMMON_MPI_SCALE "   J"  @      NLEV+COMMON_SCALE 