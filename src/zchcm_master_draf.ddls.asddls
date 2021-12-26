@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Consumo HCM_DRAFT'
@Metadata.allowExtensions: true
define root view entity ZCHCM_MASTER_DRAF
  as projection on ZIHCM_MASTER_DRAF
{
      @ObjectModel.text.element: ['EmployeeName']
  key e_number       as EmployeeNumber,
      e_name         as EmployeeName,
      e_departament  as EmployeeDepartment,
      status         as Status,
      job_title      as JobTitle,
      start_date     as StartDate,
      end_date       as EndDate,
      email          as Email,
      @ObjectModel.text.element: ['ManagerName']
      m_number       as ManagerNumber,
      m_name         as ManagerName,
      m_departament  as ManagerDepartment,
      @Semantics.user.createdBy: true
      crea_date_time as CreaDateTime,
      crea_uname     as CreaUname,
      @Semantics.user.lastChangedBy: true
      lchg_date_time as ChangeOn,
      lchg_uname     as ChangeBy
}
