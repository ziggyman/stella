procedure mnlrvcor (doit)

bool doit = YES {prompt="Do it?"}

begin
  if (doit){
    cd("/yoda/UVES/MNLupus/ready/blue")
    dorvcorlist(infilelist="single_wavelength_files_known_emission_lines_blue_hjd_vobs_to_rvcorrect.list",
	        outfile="single_wavelength_files_known_emission_lines_blue_hjd_vobs_rvcor_out.list",
	        header+,
	        input-,
	        imupdat-,
	        epoch=2000.,
	        observat="esovlt",
	        vsun=20.,
	        ra_vsun=18.,
	        dec_vsun=30.,
	        epoch_v=1900.)
    dorvcorlist(infilelist="single_wavelength_files_all_emission_lines_blue_hjd_vobs_to_rvcorrect.list",
	        outfile="single_wavelength_files_all_emission_lines_blue_hjd_vobs_rvcor_out.list",
	        header+,
	        input-,
	        imupdat-,
	        epoch=2000.,
	        observat="esovlt",
	        vsun=20.,
	        ra_vsun=18.,
	        dec_vsun=30.,
	        epoch_v=1900.)
    cd("/yoda/UVES/MNLupus/ready/red_l")
    dorvcorlist(infilelist="single_wavelength_files_known_emission_lines_l_hjd_vobs_to_rvcorrect.list",
	        outfile="single_wavelength_files_known_emission_lines_l_hjd_vobs_rvcor_out.list",
	        header+,
	        input-,
	        imupdat-,
	        epoch=2000.,
	        observat="esovlt",
	        vsun=20.,
	        ra_vsun=18.,
	        dec_vsun=30.,
	        epoch_v=1900.)
    dorvcorlist(infilelist="single_wavelength_files_all_emission_lines_l_hjd_vobs_to_rvcorrect.list",
	        outfile="single_wavelength_files_all_emission_lines_l_hjd_vobs_rvcor_out.list",
	        header+,
	        input-,
	        imupdat-,
	        epoch=2000.,
	        observat="esovlt",
	        vsun=20.,
	        ra_vsun=18.,
	        dec_vsun=30.,
	        epoch_v=1900.)
    cd("/yoda/UVES/MNLupus/ready/red_r")
    dorvcorlist(infilelist="single_wavelength_files_known_emission_lines_r_hjd_vobs_to_rvcorrect.list",
	        outfile="single_wavelength_files_known_emission_lines_r_hjd_vobs_rvcor_out.list",
	        header+,
	        input-,
	        imupdat-,
	        epoch=2000.,
	        observat="esovlt",
	        vsun=20.,
	        ra_vsun=18.,
	        dec_vsun=30.,
	        epoch_v=1900.)
    dorvcorlist(infilelist="single_wavelength_files_all_emission_lines_r_hjd_vobs_to_rvcorrect.list",
	        outfile="single_wavelength_files_all_emission_lines_r_hjd_vobs_rvcor_out.list",
	        header+,
	        input-,
	        imupdat-,
	        epoch=2000.,
	        observat="esovlt",
	        vsun=20.,
	        ra_vsun=18.,
	        dec_vsun=30.,
	        epoch_v=1900.)
  }
end
