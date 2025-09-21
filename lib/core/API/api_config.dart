abstract class APIConfig {
  static String getStorageUrl({required String path}) => path;

  static String getShareUrl({required String path}) =>
      'https://auvnet-management-system-production.up.railway.app/$path';

  static const String createEmployee = '${baseUrl}employee/createEmployee';
  static const String loginEmployee = '${baseUrl}employee/login';
  static const String updateEmployee = '${baseUrl}employee/updateEmployee';
  static const String changeEmployeeStatus =
      '${baseUrl}employee/changeEmployeeStatus';
  static const String getEmployee = '${baseUrl}employee/getEmployee';
  static const String getAllEmployees = '${baseUrl}employee/getAllEmployees';
  static const String searchEmployees = '${baseUrl}employee/searchEmployees';
  static const String deleteEmployee = '${baseUrl}employee/deleteEmployee';

  static const String baseUrl =
      'https://auvnet-management-system-production.up.railway.app/';

  /// System Admin
  static const String getAllCompanies = '/admin/getAllCompanies';
  static const String getCompany = '/admin/getCompany';
  static const String createOwner = '/admin/createOwner';
  static const String getOwner = '/admin/getOwner';
  static const String updateOwner = '/admin/updateOwner';
  static const String deleteOwner = '/admin/deleteOwner';
  static const String getAllRoles = '/role/getAllRoles';
  static const String createRole = '/role/createRole';
  static const String updateRole = '/role/updateRole';
  static const String searchRoles = '/role/searchRoles';
  static const String deleteRole = '/role/deleteRole';
  static const String getAllFinancials = '/financial/getAllFinancials';
  static const String createFinancial = '/financial/createFinancial';
  static const String updateFinancial = '/financial/updateFinancial';
  static const String searchFinancials = '/financial/searchFinancials';
  static const String deleteFinancial = '/financial/deleteFinancial';
  static const String getAllTasks = '/task/getAllTasks';
  static const String createTask = '/task/createTask';
  static const String updateTask = '/task/updateTask';
  static const String deleteTask = '/task/deleteTask';
  static const String getAllProjects = '/project/getAllProjects';
  static const String createProject = '/project/createProject';
  static const String updateProject = '/project/updateProject';
  static const String searchProjects = '/project/searchProjects';
  static const String deleteProject = '/project/deleteProject';
  static const String getAllCustomers = '/customer/getAllCustomers';
  static const String createCustomer = '/customer/createCustomer';
  static const String updateCustomer = '/customer/updateCustomer';
  static const String searchCustomers = '/customer/searchCustomers';
  static const String getCustomer = '/customer/getCustomer';
  static const String deleteCustomer = '/customer/deleteCustomer';

  ///employee note
  static const String performNote = '/note/addNote';

  ///employee report
  static const String addReport = '${baseUrl}report/addReport';
  static const String addReportReply = '${baseUrl}report/addReportReply';
  static const String getReport = '${baseUrl}report/getReport';
  static const String getAllReports = '${baseUrl}report/getAllReports';
  static const String searchReports = '${baseUrl}report/searchReports';
  static const String updateReport = '${baseUrl}report/updateReport';
  static const String deleteReport = '${baseUrl}report/deleteReport';

  // Task endpoints
  static const String createEmployeeTask = '${baseUrl}task/createTask';
  static const String getEmployeeTask = '${baseUrl}task/getTask';
  static const String getAllEmployeeTasks = '${baseUrl}task/getAllTasks';
  static const String searchEmployeeTasks = '${baseUrl}task/searchTasks';
  static const String updateEmployeeTask = '${baseUrl}task/updateTask';
  static const String deleteEmployeeTask = '${baseUrl}task/deleteTask';
  static const String updateEmployeeRole = '${baseUrl}task/updateEmployeeRole';

  /// Authentication
  static const String login = '/owner/login';
  static const String companyCompleteProfile = '';
  static const String ownerCompleteProfile = '';

  /// Products
  static const String createProduct = '/product/createProduct';
  static const String updateProduct = '/product/updateProduct';
  static const String deleteProduct = '/product/deleteProduct';
  static const String getAllProducts = '/product/getAllProducts';
  static const String getProduct = '/product/getProduct';

  /// ApiTesting
  static const String getCollections = '/apiTesting/collection/getCollections';
  static const String createCollection =
      '/apiTesting/collection/createCollection';
  static const String updateCollection =
      '/apiTesting/collection/updateCollection';
  static const String deleteCollection =
      '/apiTesting/collection/deleteCollection';
  static const String getEndpoints = '/apiTesting/endpoint/getEndpoints';
  static const String createEndpoint = '/apiTesting/endpoint/createEndpoint';
  static const String updateEndpoint = '/apiTesting/endpoint/updateEndpoint';
  static const String deleteEndpoint = '/apiTesting/endpoint/deleteEndpoint';
  static const String getFolders = '/apiTesting/folder/getFolders';
  static const String createFolder = '/apiTesting/folder/createFolder';
  static const String updateFolder = '/apiTesting/folder/updateFolder';
  static const String deleteFolder = '/apiTesting/folder/deleteFolder';
  // Mind Map
  static const String createMindMap = '/mindMap/createMindMap';
  static const String updateMindMap = '/mindMap/updateMindMap';
  static const String deleteMindMap = '/mindMap/deleteMindMap';
  static const String getAllMindMaps = '/mindMap/getAllMindMaps';
  static const String getMindMap = '/mindMap/getMindMap';
  static const String getMindMapById = '/mindMap/getMindMapById';
}
