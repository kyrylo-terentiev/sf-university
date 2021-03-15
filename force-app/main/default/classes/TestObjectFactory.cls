@isTest
public class TestObjectFactory {

    public static Employee__c createEmployee() {
        Employee__c empl = new Employee__c(
            Name = 'TestName',
            FirstName__c = 'TestFirstName',
            LastName__c = 'TestLastName',
            MiddleName__c = 'TestMiddleName',
            DateOfBirth__c = Date.newInstance(1999, 1, 1)
        );
        return empl;
    }

    public static List<Employee__c> createEmployees(Integer employeeNum) {
        List<Employee__c> employeeList = new List<Employee__c>();
        for (Integer i = 0; i < employeeNum; i++) {
            employeeList.add(createEmployee());
        }
        return employeeList;
    }

    public static Professor__c createProfessor(Employee__c employee) {
        Professor__c prof = new Professor__c(
            Name = employee.Name,
            Employee__c = employee.Id
        );
        return prof;
    }

    public static List<Professor__c> createProfessors(List<Employee__c> employeeList) {
        List<Professor__c> professorList = new List<Professor__c>();
        for (Employee__c empl : employeeList) {
            professorList.add(createProfessor(empl));
        }
        return professorList;
    }

    public static Student__c createStudent(String studentId) {
        Student__c stud = new Student__c(
            Name = 'TestName',
            FirstName__c = 'TestFirstName',
            LastName__c = 'TestLastName',
            MiddleName__c = 'TestMiddleName',
            DateOfBirth__c = Date.newInstance(1999, 1, 1),
            StudentID__c = studentId
        );
        return stud;
    }

    public static List<Student__c> createStudents(Integer studentNum, String studentIdTemplate) {
        List<Student__c> studentList = new List<Student__c>();
        for (Integer i = 0; i < studentNum; i++) {
            String ending = String.valueOf(i);
            String studentId = studentIdTemplate.substring(0, studentIdTemplate.length() - ending.length()) + ending;
            studentList.add(createStudent(studentId));
        }
        return studentList;
    }
}