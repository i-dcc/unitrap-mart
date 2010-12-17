##
## gene view
##   - used so that we have 'genes' as the top-level count
##     in the mart...
##

create or replace view `gene` as
  select * from region where region.description = 'ensembl gene'
;

##
## Add an index or two to help the mart build go faster
##

call create_index_if_not_exists('region','refseq_id_idx','refseq_id');
call create_index_if_not_exists('region','description_idx','description');
call create_index_if_not_exists('trap','gb_locus_idx','gb_locus');
call create_index_if_not_exists('esclone','strain_idx','strain');
call create_index_if_not_exists('esclone','design_type_idx','design_type');

##
## Small data updates...
##

# Set the unitrap start/end to the same as the gene when the start/end is 0
update unitrap
join region on region.region_id = unitrap.region_id
set unitrap.start = region.region_start
where unitrap.start = 0
;

update unitrap
join region on region.region_id = unitrap.region_id
set unitrap.end = region.region_end
where unitrap.end = 0
;

# Replace NA's/blanks with NULL
update region               set `refseq_id`        = null where `refseq_id`        in ( 'NA', 'na', '' );
update trap                 set `gb_locus`         = null where `gb_locus`         in ( 'NA', 'na', '' );
update trap                 set `gb_id`            = null where `gb_id`            = 0;
update trap                 set `gss_id`           = null where `gss_id`           = 0;
update esclone              set `strain`           = null where `strain`           in ( 'NA', 'na', '' );
update esclone              set `design_type`      = null where `design_type`      in ( 'NA', 'na', '' );
update trapblock_annotation set `flanking_exon_id` = null where `flanking_exon_id` = 0;

# Update the project names
update project set `project_name` = 'EGTC' where `project_name` = 'egtc';
update project set `project_name` = 'Stanford' where `project_name` = 'stanford';
update project set `project_name` = 'TIGEM' where `project_name` = 'tigem';
update project set `project_name` = 'WTSI' where `project_name` = 'sanger';
update project set `project_name` = 'Bay Genomics' where `project_name` = 'baygenomics';
update project set `project_name` = 'GGTC' where `project_name` = 'ggtc';
update project set `project_name` = 'FHCRC' where `project_name` = 'fhcrc';
update project set `project_name` = 'ESCells' where `project_name` = 'escells';
update project set `project_name` = 'Lexicon' where `project_name` = 'lexicon';
update project set `project_name` = 'Vanderbilt' where `project_name` = 'vanderbilt';
update project set `project_name` = 'NAISTRAP' where `project_name` = 'naistrap';
update project set `project_name` = 'TIGM' where `project_name` = 'tigm';
update project set `project_name` = 'CMHD' where `project_name` = 'cmhd';
