public class Utils {
    public static final Integer MAX_NAME_LENGTH = 80;
    
    public static Boolean validatePersonName(String lastName, String firstName, String middleName) {
        String regex = '^([а-яґєіїА-ЯҐЄІЇa-zA-Z])[а-яґєіїА-ЯҐЄІЇa-zA-Z- ]*([а-яґєіїА-ЯҐЄІЇa-zA-Z])$';
        Boolean matches = Pattern.compile(regex).matcher(lastName.trim()).matches()
                        && Pattern.compile(regex).matcher(firstName.trim()).matches()
                        && (!String.isEmpty(middleName) ? Pattern.compile(regex).matcher(middleName.trim()).matches() : true);
        return matches;
    }

    public static String getPersonRecordName(String lastName, String firstName, String middleName) {
        String firstMiddleNameAbbr = firstName.substring(0, 1).toUpperCase() + '. ';
        Boolean hasMiddleName = !String.isEmpty(middleName);
        Integer maxLastNameLength;
        maxLastNameLength = hasMiddleName ? MAX_NAME_LENGTH - 6 : MAX_NAME_LENGTH - 3;
        firstMiddleNameAbbr += hasMiddleName ? middleName.substring(0, 1).toUpperCase() + '.' : '';
        String lastNameAbbr = lastName.toLowerCase().capitalize().abbreviate(maxLastNameLength);
        return (lastNameAbbr + ' ' + firstMiddleNameAbbr).trim();
    }

    public static Boolean validateStudentId(String studentId) {
        String regex = '^([А-ЯҐЄІЇA-Z]{2})([0-9]{8})';
        return Pattern.compile(regex).matcher(studentId.trim()).matches();
    }
}