package pkg is 
   attribute foreign : string;
 
   procedure fsdbDumpfile (file_name : in string);
   attribute foreign of fsdbDumpfile : procedure is "fliparseTraceInit ./novas_fli.dll";
 
   procedure fsdbDumpvars (depth : in integer;
                           region_name : in string);
   attribute foreign of fsdbDumpvars : procedure is "fliparsePartial ./novas_fli.dll";
 end;
 
 package body pkg is 
     procedure fsdbDumpfile(file_name : in string) is
     begin
         assert false report "ERROR : foreign subprogram not called" severity note;
     end;
     
     procedure fsdbDumpvars(depth : in integer;
                            region_name : in string) is
     begin
         assert false report "ERROR : foreign subprogram not called" severity note;
     end;
 end; 
 
 entity novas is end; 
 
 architecture novas_arch of novas is
   attribute foreign : string;
   attribute foreign of novas_arch : architecture is "fliparseCommand novas_fli.dll";
 begin
 end;
