@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Human capital mates'
define root view entity ZIHCM_MASTER
  as select from zhcm_master as HCMMASTER
{
      //composition of target_data_source_name as _association_name {
      //    _association_name // Make association public
  key e_number       ,
      e_name         ,
      e_departament  ,
      status         ,
      job_title      ,
      start_date     ,
      end_date       ,
      email          ,
      m_number       ,
      m_name         ,
      m_departament  ,
      crea_date_time ,
      crea_uname     ,
      lchg_date_time ,
      lchg_uname     


}
