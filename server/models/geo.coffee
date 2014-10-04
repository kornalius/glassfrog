mongoose = require("mongoose")
filterPlugin = require('../mongoose_plugins/mongoose-filter')

GeoSchema = mongoose.Schema(
  code:
    type: String
    index: true
    required: true
    readOnly: true
    label: 'Code'

  name:
    type: String
    index: true
    required: true
    readOnly: true
    label: 'Name'

  cur:
    type: String
    readOnly: true
    label: 'Currency Code'
    
  'cur-name':
    type: String
    readOnly: true
    label: 'Currency Name'

  cont:
    type: String
    readOnly: true
    label: 'Continent'

  'zip-fmt':
    type: String
    readOnly: true
    label: 'Zip format'

  'zip-rx':
    type: String
    readOnly: true
    label: 'Zip RegEx'

  langs:
    type: String
    readOnly: true
    label: 'Languages'

  kind:
    type: String
    enum: ['CY', 'ST', 'CT', 'TZ']
    required: true
    readOnly: true
    label: 'Kind'

  DST:
    type: Number
    readOnly: true
    label: 'Daylight saving time'

  GMT:
    type: Number
    readOnly: true
    label: 'Greenwich Mean Time'
,
  label: 'Geo'
  readOnly: true
)

GeoSchema.plugin(filterPlugin)

module.exports = mongoose.model('Geo', GeoSchema)

setTimeout( ->
  data = [

    # Countries
    
    { code: "AD", name: "Andorra", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "AD###", 'zip-rx': "^(?:AD)*(\d{3})$", langs: "ca", kind: "CY" }
    { code: "AE", name: "United Arab Emirates", cont: "AS", cur: "AED", 'cur-name': "Dirham", 'zip-fmt': "", 'zip-rx': "", langs: "ar-AE,fa,en,hi,ur", kind: "CY" }
    { code: "AF", name: "Afghanistan", cont: "AS", cur: "AFN", 'cur-name': "Afghani", 'zip-fmt': "", 'zip-rx': "", langs: "fa-AF,ps,uz-AF,tk", kind: "CY" }
    { code: "AG", name: "Antigua and Barbuda", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-AG", kind: "CY" }
    { code: "AI", name: "Anguilla", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-AI", kind: "CY" }
    { code: "AL", name: "Albania", cont: "EU", cur: "ALL", 'cur-name': "Lek", 'zip-fmt': "", 'zip-rx': "", langs: "sq,el", kind: "CY" }
    { code: "AM", name: "Armenia", cont: "AS", cur: "AMD", 'cur-name': "Dram", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "hy", kind: "CY" }
    { code: "AO", name: "Angola", cont: "AF", cur: "AOA", 'cur-name': "Kwanza", 'zip-fmt': "", 'zip-rx': "", langs: "pt-AO", kind: "CY" }
    { code: "AQ", name: "Antarctica", cont: "AN", cur: "", 'cur-name': "", 'zip-fmt': "", 'zip-rx': "", langs: "", kind: "CY" }
    { code: "AR", name: "Argentina", cont: "SA", cur: "ARS", 'cur-name': "Peso", 'zip-fmt': "@####@@@", 'zip-rx': "^([A-Z]\d{4}[A-Z]{3})$", langs: "es-AR,en,it,de,fr,gn", kind: "CY" }
    { code: "AS", name: "American Samoa", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-AS,sm,to", kind: "CY" }
    { code: "AT", name: "Austria", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "de-AT,hr,hu,sl", kind: "CY" }
    { code: "AU", name: "Australia", cont: "OC", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "en-AU", kind: "CY" }
    { code: "AW", name: "Aruba", cont: "NA", cur: "AWG", 'cur-name': "Guilder", 'zip-fmt': "", 'zip-rx': "", langs: "nl-AW,es,en", kind: "CY" }
    { code: "AX", name: "Aland Islands", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "", 'zip-rx': "", langs: "sv-AX", kind: "CY" }
    { code: "AZ", name: "Azerbaijan", cont: "AS", cur: "AZN", 'cur-name': "Manat", 'zip-fmt': "AZ ####", 'zip-rx': "^(?:AZ)*(\d{4})$", langs: "az,ru,hy", kind: "CY" }
    { code: "BA", name: "Bosnia and Herzegovina", cont: "EU", cur: "BAM", 'cur-name': "Marka", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "bs,hr-BA,sr-BA", kind: "CY" }
    { code: "BB", name: "Barbados", cont: "NA", cur: "BBD", 'cur-name': "Dollar", 'zip-fmt': "BB#####", 'zip-rx': "^(?:BB)*(\d{5})$", langs: "en-BB", kind: "CY" }
    { code: "BD", name: "Bangladesh", cont: "AS", cur: "BDT", 'cur-name': "Taka", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "bn-BD,en", kind: "CY" }
    { code: "BE", name: "Belgium", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "nl-BE,fr-BE,de-BE", kind: "CY" }
    { code: "BF", name: "Burkina Faso", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-BF", kind: "CY" }
    { code: "BG", name: "Bulgaria", cont: "EU", cur: "BGN", 'cur-name': "Lev", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "bg,tr-BG", kind: "CY" }
    { code: "BH", name: "Bahrain", cont: "AS", cur: "BHD", 'cur-name': "Dinar", 'zip-fmt': "####|###", 'zip-rx': "^(\d{3}\d?)$", langs: "ar-BH,en,fa,ur", kind: "CY" }
    { code: "BI", name: "Burundi", cont: "AF", cur: "BIF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-BI,rn", kind: "CY" }
    { code: "BJ", name: "Benin", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-BJ", kind: "CY" }
    { code: "BL", name: "Saint Barthelemy", cont: "NA", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "### ###", 'zip-rx': "", langs: "fr", kind: "CY" }
    { code: "BM", name: "Bermuda", cont: "NA", cur: "BMD", 'cur-name': "Dollar", 'zip-fmt': "@@ ##", 'zip-rx': "^([A-Z]{2}\d{2})$", langs: "en-BM,pt", kind: "CY" }
    { code: "BN", name: "Brunei", cont: "AS", cur: "BND", 'cur-name': "Dollar", 'zip-fmt': "@@####", 'zip-rx': "^([A-Z]{2}\d{4})$", langs: "ms-BN,en-BN", kind: "CY" }
    { code: "BO", name: "Bolivia", cont: "SA", cur: "BOB", 'cur-name': "Boliviano", 'zip-fmt': "", 'zip-rx': "", langs: "es-BO,qu,ay", kind: "CY" }
    { code: "BQ", name: "Bonaire, Saint Eustatius and Saba" , cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "nl,pap,en", kind: "CY" }
    { code: "BR", name: "Brazil", cont: "SA", cur: "BRL", 'cur-name': "Real", 'zip-fmt': "#####-###", 'zip-rx': "^(\d{8})$", langs: "pt-BR,es,en,fr", kind: "CY" }
    { code: "BS", name: "Bahamas", cont: "NA", cur: "BSD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-BS", kind: "CY" }
    { code: "BT", name: "Bhutan", cont: "AS", cur: "BTN", 'cur-name': "Ngultrum", 'zip-fmt': "", 'zip-rx': "", langs: "dz", kind: "CY" }
    { code: "BV", name: "Bouvet Island", cont: "AN", cur: "NOK", 'cur-name': "Krone", 'zip-fmt': "", 'zip-rx': "", langs: "", kind: "CY" }
    { code: "BW", name: "Botswana", cont: "AF", cur: "BWP", 'cur-name': "Pula", 'zip-fmt': "", 'zip-rx': "", langs: "en-BW,tn-BW", kind: "CY" }
    { code: "BY", name: "Belarus", cont: "EU", cur: "BYR", 'cur-name': "Ruble", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "be,ru", kind: "CY" }
    { code: "BZ", name: "Belize", cont: "NA", cur: "BZD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-BZ,es", kind: "CY" }
    { code: "CA", name: "Canada", cont: "NA", cur: "CAD", 'cur-name': "Dollar", 'zip-fmt': "@#@ #@#", 'zip-rx': "^([ABCEGHJKLMNPRSTVXY]\d[ABCEGHJKLMNPRSTVWXYZ]) ?(\d[ABCEGHJKLMNPRSTVWXYZ]\d)$ ", langs: "en-CA,fr-CA,iu", kind: "CY" }
    { code: "CC", name: "Cocos Islands", cont: "AS", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "ms-CC,en", kind: "CY" }
    { code: "CD", name: "Democratic Republic of the Congo", cont: "AF", cur: "CDF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-CD,ln,kg", kind: "CY" }
    { code: "CF", name: "Central African Republic", cont: "AF", cur: "XAF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-CF,sg,ln,kg", kind: "CY" }
    { code: "CG", name: "Republic of the Congo", cont: "AF", cur: "XAF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-CG,kg,ln-CG", kind: "CY" }
    { code: "CH", name: "Switzerland", cont: "EU", cur: "CHF", 'cur-name': "Franc", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "de-CH,fr-CH,it-CH,rm", kind: "CY" }
    { code: "CI", name: "Ivory Coast", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-CI", kind: "CY" }
    { code: "CK", name: "Cook Islands", cont: "OC", cur: "NZD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-CK,mi", kind: "CY" }
    { code: "CL", name: "Chile", cont: "SA", cur: "CLP", 'cur-name': "Peso", 'zip-fmt': "#######", 'zip-rx': "^(\d{7})$", langs: "es-CL", kind: "CY" }
    { code: "CM", name: "Cameroon", cont: "AF", cur: "XAF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "en-CM,fr-CM", kind: "CY" }
    { code: "CN", name: "China", cont: "AS", cur: "CNY", 'cur-name': "Yuan Renminbi", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "zh-CN,yue,wuu,dta,ug,za", kind: "CY" }
    { code: "CO", name: "Colombia", cont: "SA", cur: "COP", 'cur-name': "Peso", 'zip-fmt': "", 'zip-rx': "", langs: "es-CO", kind: "CY" }
    { code: "CR", name: "Costa Rica", cont: "NA", cur: "CRC", 'cur-name': "Colon", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "es-CR,en", kind: "CY" }
    { code: "CU", name: "Cuba", cont: "NA", cur: "CUP", 'cur-name': "Peso", 'zip-fmt': "CP #####", 'zip-rx': "^(?:CP)*(\d{5})$", langs: "es-CU", kind: "CY" }
    { code: "CV", name: "Cape Verde", cont: "AF", cur: "CVE", 'cur-name': "Escudo", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "pt-CV", kind: "CY" }
    { code: "CW", name: "Curacao", cont: "NA", cur: "ANG", 'cur-name': "Guilder", 'zip-fmt': "", 'zip-rx': "", langs: "nl,pap", kind: "CY" }
    { code: "CX", name: "Christmas Island", cont: "AS", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "en,zh,ms-CC", kind: "CY" }
    { code: "CY", name: "Cyprus", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "el-CY,tr-CY,en", kind: "CY" }
    { code: "CZ", name: "Czech Republic", cont: "EU", cur: "CZK", 'cur-name': "Koruna", 'zip-fmt': "### ##", 'zip-rx': "^(\d{5})$", langs: "cs,sk", kind: "CY" }
    { code: "DE", name: "Germany", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "de", kind: "CY" }
    { code: "DJ", name: "Djibouti", cont: "AF", cur: "DJF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-DJ,ar,so-DJ,aa", kind: "CY" }
    { code: "DK", name: "Denmark", cont: "EU", cur: "DKK", 'cur-name': "Krone", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "da-DK,en,fo,de-DK", kind: "CY" }
    { code: "DM", name: "Dominica", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-DM", kind: "CY" }
    { code: "DO", name: "Dominican Republic", cont: "NA", cur: "DOP", 'cur-name': "Peso", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "es-DO", kind: "CY" }
    { code: "DZ", name: "Algeria", cont: "AF", cur: "DZD", 'cur-name': "Dinar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-DZ", kind: "CY" }
    { code: "EC", name: "Ecuador", cont: "SA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "@####@", 'zip-rx': "^([a-zA-Z]\d{4}[a-zA-Z])$", langs: "es-EC", kind: "CY" }
    { code: "EE", name: "Estonia", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "et,ru", kind: "CY" }
    { code: "EG", name: "Egypt", cont: "AF", cur: "EGP", 'cur-name': "Pound", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-EG,en,fr", kind: "CY" }
    { code: "EH", name: "Western Sahara", cont: "AF", cur: "MAD", 'cur-name': "Dirham", 'zip-fmt': "", 'zip-rx': "", langs: "ar,mey", kind: "CY" }
    { code: "ER", name: "Eritrea", cont: "AF", cur: "ERN", 'cur-name': "Nakfa", 'zip-fmt': "", 'zip-rx': "", langs: "aa-ER,ar,tig,kun,ti-ER", kind: "CY" }
    { code: "ES", name: "Spain", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "es-ES,ca,gl,eu,oc", kind: "CY" }
    { code: "ET", name: "Ethiopia", cont: "AF", cur: "ETB", 'cur-name': "Birr", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "am,en-ET,om-ET,ti-ET,so-ET,sid", kind: "CY" }
    { code: "FI", name: "Finland", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(?:FI)*(\d{5})$", langs: "fi-FI,sv-FI,smn", kind: "CY" }
    { code: "FJ", name: "Fiji", cont: "OC", cur: "FJD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-FJ,fj", kind: "CY" }
    { code: "FK", name: "Falkland Islands", cont: "SA", cur: "FKP", 'cur-name': "Pound", 'zip-fmt': "", 'zip-rx': "", langs: "en-FK", kind: "CY" }
    { code: "FM", name: "Micronesia", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "en-FM,chk,pon,yap,kos,uli,woe,nkr,kpg", kind: "CY" }
    { code: "FO", name: "Faroe Islands", cont: "EU", cur: "DKK", 'cur-name': "Krone", 'zip-fmt': "FO-###", 'zip-rx': "^(?:FO)*(\d{3})$", langs: "fo,da-FO", kind: "CY" }
    { code: "FR", name: "France", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "fr-FR,frp,br,co,ca,eu,oc", kind: "CY" }
    { code: "GA", name: "Gabon", cont: "AF", cur: "XAF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-GA", kind: "CY" }
    { code: "GB", name: "United Kingdom", cont: "EU", cur: "GBP", 'cur-name': "Pound", 'zip-fmt': "@# #@@|@## #@@|@@# #@@|@@## #@@|@#@ #@@|@@#@ #@@|GIR0AA", 'zip-rx': "^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$", langs: "en-GB,cy-GB,gd", kind: "CY" }
    { code: "GD", name: "Grenada", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-GD", kind: "CY" }
    { code: "GE", name: "Georgia", cont: "AS", cur: "GEL", 'cur-name': "Lari", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "ka,ru,hy,az", kind: "CY" }
    { code: "GF", name: "French Guiana", cont: "SA", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^((97|98)3\d{2})$", langs: "fr-GF", kind: "CY" }
    { code: "GG", name: "Guernsey", cont: "EU", cur: "GBP", 'cur-name': "Pound", 'zip-fmt': "@# #@@|@## #@@|@@# #@@|@@## #@@|@#@ #@@|@@#@ #@@|GIR0AA", 'zip-rx': "^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$", langs: "en,fr", kind: "CY" }
    { code: "GH", name: "Ghana", cont: "AF", cur: "GHS", 'cur-name': "Cedi", 'zip-fmt': "", 'zip-rx': "", langs: "en-GH,ak,ee,tw", kind: "CY" }
    { code: "GI", name: "Gibraltar", cont: "EU", cur: "GIP", 'cur-name': "Pound", 'zip-fmt': "", 'zip-rx': "", langs: "en-GI,es,it,pt", kind: "CY" }
    { code: "GL", name: "Greenland", cont: "NA", cur: "DKK", 'cur-name': "Krone", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "kl,da-GL,en", kind: "CY" }
    { code: "GM", name: "Gambia", cont: "AF", cur: "GMD", 'cur-name': "Dalasi", 'zip-fmt': "", 'zip-rx': "", langs: "en-GM,mnk,wof,wo,ff", kind: "CY" }
    { code: "GN", name: "Guinea", cont: "AF", cur: "GNF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-GN", kind: "CY" }
    { code: "GP", name: "Guadeloupe", cont: "NA", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^((97|98)\d{3})$", langs: "fr-GP", kind: "CY" }
    { code: "GQ", name: "Equatorial Guinea", cont: "AF", cur: "XAF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "es-GQ,fr", kind: "CY" }
    { code: "GR", name: "Greece", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "### ##", 'zip-rx': "^(\d{5})$", langs: "el-GR,en,fr", kind: "CY" }
    { code: "GS", name: "South Georgia and the South Sandwich Islands", cont: "AN", cur: "GBP", 'cur-name': "Pound", 'zip-fmt': "", 'zip-rx': "", langs: "en", kind: "CY" }
    { code: "GT", name: "Guatemala", cont: "NA", cur: "GTQ", 'cur-name': "Quetzal", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "es-GT", kind: "CY" }
    { code: "GU", name: "Guam", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "969##", 'zip-rx': "^(969\d{2})$", langs: "en-GU,ch-GU", kind: "CY" }
    { code: "GW", name: "Guinea-Bissau", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "pt-GW,pov", kind: "CY" }
    { code: "GY", name: "Guyana", cont: "SA", cur: "GYD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-GY", kind: "CY" }
    { code: "HK", name: "Hong Kong", cont: "AS", cur: "HKD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "zh-HK,yue,zh,en", kind: "CY" }
    { code: "HM", name: "Heard Island and McDonald Islands", cont: "AN", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "", kind: "CY" }
    { code: "HN", name: "Honduras", cont: "NA", cur: "HNL", 'cur-name': "Lempira", 'zip-fmt': "@@####", 'zip-rx': "^([A-Z]{2}\d{4})$", langs: "es-HN", kind: "CY" }
    { code: "HR", name: "Croatia", cont: "EU", cur: "HRK", 'cur-name': "Kuna", 'zip-fmt': "#####", 'zip-rx': "^(?:HR)*(\d{5})$", langs: "hr-HR,sr", kind: "CY" }
    { code: "HT", name: "Haiti", cont: "NA", cur: "HTG", 'cur-name': "Gourde", 'zip-fmt': "HT####", 'zip-rx': "^(?:HT)*(\d{4})$", langs: "ht,fr-HT", kind: "CY" }
    { code: "HU", name: "Hungary", cont: "EU", cur: "HUF", 'cur-name': "Forint", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "hu-HU", kind: "CY" }
    { code: "ID", name: "Indonesia", cont: "AS", cur: "IDR", 'cur-name': "Rupiah", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "id,en,nl,jv", kind: "CY" }
    { code: "IE", name: "Ireland", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "", 'zip-rx': "", langs: "en-IE,ga-IE", kind: "CY" }
    { code: "IL", name: "Israel", cont: "AS", cur: "ILS", 'cur-name': "Shekel", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "he,ar-IL,en-IL,", kind: "CY" }
    { code: "IM", name: "Isle of Man", cont: "EU", cur: "GBP", 'cur-name': "Pound", 'zip-fmt': "@# #@@|@## #@@|@@# #@@|@@## #@@|@#@ #@@|@@#@ #@@|GIR0AA", 'zip-rx': "^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$", langs: "en,gv", kind: "CY" }
    { code: "IN", name: "India", cont: "AS", cur: "INR", 'cur-name': "Rupee", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "en-IN,hi,bn,te,mr,ta,ur,gu,kn,ml,or,pa,as,bh,sat,ks,ne,sd,kok,doi,mni,sit,sa,fr,lus,inc", kind: "CY" }
    { code: "IO", name: "British Indian Ocean Territory", cont: "AS", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-IO", kind: "CY" }
    { code: "IQ", name: "Iraq", cont: "AS", cur: "IQD", 'cur-name': "Dinar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-IQ,ku,hy", kind: "CY" }
    { code: "IR", name: "Iran", cont: "AS", cur: "IRR", 'cur-name': "Rial", 'zip-fmt': "##########", 'zip-rx': "^(\d{10})$", langs: "fa-IR,ku", kind: "CY" }
    { code: "IS", name: "Iceland", cont: "EU", cur: "ISK", 'cur-name': "Krona", 'zip-fmt': "###", 'zip-rx': "^(\d{3})$", langs: "is,en,de,da,sv,no", kind: "CY" }
    { code: "IT", name: "Italy", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "it-IT,de-IT,fr-IT,sc,ca,co,sl", kind: "CY" }
    { code: "JE", name: "Jersey", cont: "EU", cur: "GBP", 'cur-name': "Pound", 'zip-fmt': "@# #@@|@## #@@|@@# #@@|@@## #@@|@#@ #@@|@@#@ #@@|GIR0AA", 'zip-rx': "^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$", langs: "en,pt", kind: "CY" }
    { code: "JM", name: "Jamaica", cont: "NA", cur: "JMD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-JM", kind: "CY" }
    { code: "JO", name: "Jordan", cont: "AS", cur: "JOD", 'cur-name': "Dinar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-JO,en", kind: "CY" }
    { code: "JP", name: "Japan", cont: "AS", cur: "JPY", 'cur-name': "Yen", 'zip-fmt': "###-####", 'zip-rx': "^(\d{7})$", langs: "ja", kind: "CY" }
    { code: "KE", name: "Kenya", cont: "AF", cur: "KES", 'cur-name': "Shilling", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "en-KE,sw-KE", kind: "CY" }
    { code: "KG", name: "Kyrgyzstan", cont: "AS", cur: "KGS", 'cur-name': "Som", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "ky,uz,ru", kind: "CY" }
    { code: "KH", name: "Cambodia", cont: "AS", cur: "KHR", 'cur-name': "Riels", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "km,fr,en", kind: "CY" }
    { code: "KI", name: "Kiribati", cont: "OC", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-KI,gil", kind: "CY" }
    { code: "KM", name: "Comoros", cont: "AF", cur: "KMF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "ar,fr-KM", kind: "CY" }
    { code: "KN", name: "Saint Kitts and Nevis", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-KN", kind: "CY" }
    { code: "KP", name: "North Korea", cont: "AS", cur: "KPW", 'cur-name': "Won", 'zip-fmt': "###-###", 'zip-rx': "^(\d{6})$", langs: "ko-KP", kind: "CY" }
    { code: "KR", name: "South Korea", cont: "AS", cur: "KRW", 'cur-name': "Won", 'zip-fmt': "SEOUL ###-###", 'zip-rx': "^(?:SEOUL)*(\d{6})$", langs: "ko-KR,en", kind: "CY" }
    { code: "XK", name: "Kosovo", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "", 'zip-rx': "", langs: "sq,sr", kind: "CY" }
    { code: "KW", name: "Kuwait", cont: "AS", cur: "KWD", 'cur-name': "Dinar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-KW,en", kind: "CY" }
    { code: "KY", name: "Cayman Islands", cont: "NA", cur: "KYD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-KY", kind: "CY" }
    { code: "KZ", name: "Kazakhstan", cont: "AS", cur: "KZT", 'cur-name': "Tenge", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "kk,ru", kind: "CY" }
    { code: "LA", name: "Laos", cont: "AS", cur: "LAK", 'cur-name': "Kip", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "lo,fr,en", kind: "CY" }
    { code: "LB", name: "Lebanon", cont: "AS", cur: "LBP", 'cur-name': "Pound", 'zip-fmt': "#### ####|####", 'zip-rx': "^(\d{4}(\d{4})?)$", langs: "ar-LB,fr-LB,en,hy", kind: "CY" }
    { code: "LC", name: "Saint Lucia", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-LC", kind: "CY" }
    { code: "LI", name: "Liechtenstein", cont: "EU", cur: "CHF", 'cur-name': "Franc", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "de-LI", kind: "CY" }
    { code: "LK", name: "Sri Lanka", cont: "AS", cur: "LKR", 'cur-name': "Rupee", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "si,ta,en", kind: "CY" }
    { code: "LR", name: "Liberia", cont: "AF", cur: "LRD", 'cur-name': "Dollar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "en-LR", kind: "CY" }
    { code: "LS", name: "Lesotho", cont: "AF", cur: "LSL", 'cur-name': "Loti", 'zip-fmt': "###", 'zip-rx': "^(\d{3})$", langs: "en-LS,st,zu,xh", kind: "CY" }
    { code: "LT", name: "Lithuania", cont: "EU", cur: "LTL", 'cur-name': "Litas", 'zip-fmt': "LT-#####", 'zip-rx': "^(?:LT)*(\d{5})$", langs: "lt,ru,pl", kind: "CY" }
    { code: "LU", name: "Luxembourg", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "lb,de-LU,fr-LU", kind: "CY" }
    { code: "LV", name: "Latvia", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "LV-####", 'zip-rx': "^(?:LV)*(\d{4})$", langs: "lv,ru,lt", kind: "CY" }
    { code: "LY", name: "Libya", cont: "AF", cur: "LYD", 'cur-name': "Dinar", 'zip-fmt': "", 'zip-rx': "", langs: "ar-LY,it,en", kind: "CY" }
    { code: "MA", name: "Morocco", cont: "AF", cur: "MAD", 'cur-name': "Dirham", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-MA,fr", kind: "CY" }
    { code: "MC", name: "Monaco", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "fr-MC,en,it", kind: "CY" }
    { code: "MD", name: "Moldova", cont: "EU", cur: "MDL", 'cur-name': "Leu", 'zip-fmt': "MD-####", 'zip-rx': "^(?:MD)*(\d{4})$", langs: "ro,ru,gag,tr", kind: "CY" }
    { code: "ME", name: "Montenegro", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "sr,hu,bs,sq,hr,rom", kind: "CY" }
    { code: "MF", name: "Saint Martin", cont: "NA", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "### ###", 'zip-rx': "", langs: "fr", kind: "CY" }
    { code: "MG", name: "Madagascar", cont: "AF", cur: "MGA", 'cur-name': "Ariary", 'zip-fmt': "###", 'zip-rx': "^(\d{3})$", langs: "fr-MG,mg", kind: "CY" }
    { code: "MH", name: "Marshall Islands", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "mh,en-MH", kind: "CY" }
    { code: "MK", name: "Macedonia", cont: "EU", cur: "MKD", 'cur-name': "Denar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "mk,sq,tr,rmm,sr", kind: "CY" }
    { code: "ML", name: "Mali", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-ML,bm", kind: "CY" }
    { code: "MM", name: "Myanmar", cont: "AS", cur: "MMK", 'cur-name': "Kyat", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "my", kind: "CY" }
    { code: "MN", name: "Mongolia", cont: "AS", cur: "MNT", 'cur-name': "Tugrik", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "mn,ru", kind: "CY" }
    { code: "MO", name: "Macao", cont: "AS", cur: "MOP", 'cur-name': "Pataca", 'zip-fmt': "", 'zip-rx': "", langs: "zh,zh-MO,pt", kind: "CY" }
    { code: "MP", name: "Northern Mariana Islands", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "fil,tl,zh,ch-MP,en-MP", kind: "CY" }
    { code: "MQ", name: "Martinique", cont: "NA", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "fr-MQ", kind: "CY" }
    { code: "MR", name: "Mauritania", cont: "AF", cur: "MRO", 'cur-name': "Ouguiya", 'zip-fmt': "", 'zip-rx': "", langs: "ar-MR,fuc,snk,fr,mey,wo", kind: "CY" }
    { code: "MS", name: "Montserrat", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-MS", kind: "CY" }
    { code: "MT", name: "Malta", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "@@@ ###|@@@ ##", 'zip-rx': "^([A-Z]{3}\d{2}\d?)$", langs: "mt,en-MT", kind: "CY" }
    { code: "MU", name: "Mauritius", cont: "AF", cur: "MUR", 'cur-name': "Rupee", 'zip-fmt': "", 'zip-rx': "", langs: "en-MU,bho,fr", kind: "CY" }
    { code: "MV", name: "Maldives", cont: "AS", cur: "MVR", 'cur-name': "Rufiyaa", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "dv,en", kind: "CY" }
    { code: "MW", name: "Malawi", cont: "AF", cur: "MWK", 'cur-name': "Kwacha", 'zip-fmt': "", 'zip-rx': "", langs: "ny,yao,tum,swk", kind: "CY" }
    { code: "MX", name: "Mexico", cont: "NA", cur: "MXN", 'cur-name': "Peso", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "es-MX", kind: "CY" }
    { code: "MY", name: "Malaysia", cont: "AS", cur: "MYR", 'cur-name': "Ringgit", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ms-MY,en,zh,ta,te,ml,pa,th", kind: "CY" }
    { code: "MZ", name: "Mozambique", cont: "AF", cur: "MZN", 'cur-name': "Metical", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "pt-MZ,vmw", kind: "CY" }
    { code: "NA", name: "Namibia", cont: "AF", cur: "NAD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-NA,af,de,hz,naq", kind: "CY" }
    { code: "NC", name: "New Caledonia", cont: "OC", cur: "XPF", 'cur-name': "Franc", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "fr-NC", kind: "CY" }
    { code: "NE", name: "Niger", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "fr-NE,ha,kr,dje", kind: "CY" }
    { code: "NF", name: "Norfolk Island", cont: "OC", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "en-NF", kind: "CY" }
    { code: "NG", name: "Nigeria", cont: "AF", cur: "NGN", 'cur-name': "Naira", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "en-NG,ha,yo,ig,ff", kind: "CY" }
    { code: "NI", name: "Nicaragua", cont: "NA", cur: "NIO", 'cur-name': "Cordoba", 'zip-fmt': "###-###-#", 'zip-rx': "^(\d{7})$", langs: "es-NI,en", kind: "CY" }
    { code: "NL", name: "Netherlands", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#### @@", 'zip-rx': "^(\d{4}[A-Z]{2})$", langs: "nl-NL,fy-NL", kind: "CY" }
    { code: "NO", name: "Norway", cont: "EU", cur: "NOK", 'cur-name': "Krone", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "no,nb,nn,se,fi", kind: "CY" }
    { code: "NP", name: "Nepal", cont: "AS", cur: "NPR", 'cur-name': "Rupee", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ne,en", kind: "CY" }
    { code: "NR", name: "Nauru", cont: "OC", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "na,en-NR", kind: "CY" }
    { code: "NU", name: "Niue", cont: "OC", cur: "NZD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "niu,en-NU", kind: "CY" }
    { code: "NZ", name: "New Zealand", cont: "OC", cur: "NZD", 'cur-name': "Dollar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "en-NZ,mi", kind: "CY" }
    { code: "OM", name: "Oman", cont: "AS", cur: "OMR", 'cur-name': "Rial", 'zip-fmt': "###", 'zip-rx': "^(\d{3})$", langs: "ar-OM,en,bal,ur", kind: "CY" }
    { code: "PA", name: "Panama", cont: "NA", cur: "PAB", 'cur-name': "Balboa", 'zip-fmt': "", 'zip-rx': "", langs: "es-PA,en", kind: "CY" }
    { code: "PE", name: "Peru", cont: "SA", cur: "PEN", 'cur-name': "Sol", 'zip-fmt': "", 'zip-rx': "", langs: "es-PE,qu,ay", kind: "CY" }
    { code: "PF", name: "French Polynesia", cont: "OC", cur: "XPF", 'cur-name': "Franc", 'zip-fmt': "#####", 'zip-rx': "^((97|98)7\d{2})$", langs: "fr-PF,ty", kind: "CY" }
    { code: "PG", name: "Papua New Guinea", cont: "OC", cur: "PGK", 'cur-name': "Kina", 'zip-fmt': "###", 'zip-rx': "^(\d{3})$", langs: "en-PG,ho,meu,tpi", kind: "CY" }
    { code: "PH", name: "Philippines", cont: "AS", cur: "PHP", 'cur-name': "Peso", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "tl,en-PH,fil", kind: "CY" }
    { code: "PK", name: "Pakistan", cont: "AS", cur: "PKR", 'cur-name': "Rupee", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ur-PK,en-PK,pa,sd,ps,brh", kind: "CY" }
    { code: "PL", name: "Poland", cont: "EU", cur: "PLN", 'cur-name': "Zloty", 'zip-fmt': "##-###", 'zip-rx': "^(\d{5})$", langs: "pl", kind: "CY" }
    { code: "PM", name: "Saint Pierre and Miquelon", cont: "NA", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(97500)$", langs: "fr-PM", kind: "CY" }
    { code: "PN", name: "Pitcairn", cont: "OC", cur: "NZD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-PN", kind: "CY" }
    { code: "PR", name: "Puerto Rico", cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "#####-####", 'zip-rx': "^(\d{9})$", langs: "en-PR,es-PR", kind: "CY" }
    { code: "PS", name: "Palestinian Territory", cont: "AS", cur: "ILS", 'cur-name': "Shekel", 'zip-fmt': "", 'zip-rx': "", langs: "ar-PS", kind: "CY" }
    { code: "PT", name: "Portugal", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "####-###", 'zip-rx': "^(\d{7})$", langs: "pt-PT,mwl", kind: "CY" }
    { code: "PW", name: "Palau", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "96940", 'zip-rx': "^(96940)$", langs: "pau,sov,en-PW,tox,ja,fil,zh", kind: "CY" }
    { code: "PY", name: "Paraguay", cont: "SA", cur: "PYG", 'cur-name': "Guarani", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "es-PY,gn", kind: "CY" }
    { code: "QA", name: "Qatar", cont: "AS", cur: "QAR", 'cur-name': "Rial", 'zip-fmt': "", 'zip-rx': "", langs: "ar-QA,es", kind: "CY" }
    { code: "RE", name: "Reunion", cont: "AF", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^((97|98)(4|7|8)\d{2})$", langs: "fr-RE", kind: "CY" }
    { code: "RO", name: "Romania", cont: "EU", cur: "RON", 'cur-name': "Leu", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "ro,hu,rom", kind: "CY" }
    { code: "RS", name: "Serbia", cont: "EU", cur: "RSD", 'cur-name': "Dinar", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "sr,hu,bs,rom", kind: "CY" }
    { code: "RU", name: "Russia", cont: "EU", cur: "RUB", 'cur-name': "Ruble", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "ru,tt,xal,cau,ady,kv,ce,tyv,cv,udm,tut,mns,bua,myv,mdf,chm,ba,inh,tut,kbd,krc,ava,sah,nog", kind: "CY" }
    { code: "RW", name: "Rwanda", cont: "AF", cur: "RWF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "rw,en-RW,fr-RW,sw", kind: "CY" }
    { code: "SA", name: "Saudi Arabia", cont: "AS", cur: "SAR", 'cur-name': "Rial", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-SA", kind: "CY" }
    { code: "SB", name: "Solomon Islands", cont: "OC", cur: "SBD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-SB,tpi", kind: "CY" }
    { code: "SC", name: "Seychelles", cont: "AF", cur: "SCR", 'cur-name': "Rupee", 'zip-fmt': "", 'zip-rx': "", langs: "en-SC,fr-SC", kind: "CY" }
    { code: "SD", name: "Sudan", cont: "AF", cur: "SDG", 'cur-name': "Pound", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "ar-SD,en,fia", kind: "CY" }
    { code: "SS", name: "South Sudan", cont: "AF", cur: "SSP", 'cur-name': "Pound", 'zip-fmt': "", 'zip-rx': "", langs: "en", kind: "CY" }
    { code: "SE", name: "Sweden", cont: "EU", cur: "SEK", 'cur-name': "Krona", 'zip-fmt': "### ##", 'zip-rx': "^(?:SE)*(\d{5})$", langs: "sv-SE,se,sma,fi-SE", kind: "CY" }
    { code: "SG", name: "Singapore", cont: "AS", cur: "SGD", 'cur-name': "Dollar", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "cmn,en-SG,ms-SG,ta-SG,zh-SG", kind: "CY" }
    { code: "SH", name: "Saint Helena", cont: "AF", cur: "SHP", 'cur-name': "Pound", 'zip-fmt': "STHL 1ZZ", 'zip-rx': "^(STHL1ZZ)$", langs: "en-SH", kind: "CY" }
    { code: "SI", name: "Slovenia", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "####", 'zip-rx': "^(?:SI)*(\d{4})$", langs: "sl,sh", kind: "CY" }
    { code: "SJ", name: "Svalbard and Jan Mayen", cont: "EU", cur: "NOK", 'cur-name': "Krone", 'zip-fmt': "", 'zip-rx': "", langs: "no,ru", kind: "CY" }
    { code: "SK", name: "Slovakia", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "### ##", 'zip-rx': "^(\d{5})$", langs: "sk,hu", kind: "CY" }
    { code: "SL", name: "Sierra Leone", cont: "AF", cur: "SLL", 'cur-name': "Leone", 'zip-fmt': "", 'zip-rx': "", langs: "en-SL,men,tem", kind: "CY" }
    { code: "SM", name: "San Marino", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "4789#", 'zip-rx': "^(4789\d)$", langs: "it-SM", kind: "CY" }
    { code: "SN", name: "Senegal", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "fr-SN,wo,fuc,mnk", kind: "CY" }
    { code: "SO", name: "Somalia", cont: "AF", cur: "SOS", 'cur-name': "Shilling", 'zip-fmt': "@@  #####", 'zip-rx': "^([A-Z]{2}\d{5})$", langs: "so-SO,ar-SO,it,en-SO", kind: "CY" }
    { code: "SR", name: "Suriname", cont: "SA", cur: "SRD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "nl-SR,en,srn,hns,jv", kind: "CY" }
    { code: "ST", name: "Sao Tome and Principe", cont: "AF", cur: "STD", 'cur-name': "Dobra", 'zip-fmt': "", 'zip-rx': "", langs: "pt-ST", kind: "CY" }
    { code: "SV", name: "El Salvador", cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "CP ####", 'zip-rx': "^(?:CP)*(\d{4})$", langs: "es-SV", kind: "CY" }
    { code: "SX", name: "Sint Maarten", cont: "NA", cur: "ANG", 'cur-name': "Guilder", 'zip-fmt': "", 'zip-rx': "", langs: "nl,en", kind: "CY" }
    { code: "SY", name: "Syria", cont: "AS", cur: "SYP", 'cur-name': "Pound", 'zip-fmt': "", 'zip-rx': "", langs: "ar-SY,ku,hy,arc,fr,en", kind: "CY" }
    { code: "SZ", name: "Swaziland", cont: "AF", cur: "SZL", 'cur-name': "Lilangeni", 'zip-fmt': "@###", 'zip-rx': "^([A-Z]\d{3})$", langs: "en-SZ,ss-SZ", kind: "CY" }
    { code: "TC", name: "Turks and Caicos Islands", cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "TKCA 1ZZ", 'zip-rx': "^(TKCA 1ZZ)$", langs: "en-TC", kind: "CY" }
    { code: "TD", name: "Chad", cont: "AF", cur: "XAF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-TD,ar-TD,sre", kind: "CY" }
    { code: "TF", name: "French Southern Territories", cont: "AN", cur: "EUR", 'cur-name': "Euro  ", 'zip-fmt': "", 'zip-rx': "", langs: "fr", kind: "CY" }
    { code: "TG", name: "Togo", cont: "AF", cur: "XOF", 'cur-name': "Franc", 'zip-fmt': "", 'zip-rx': "", langs: "fr-TG,ee,hna,kbp,dag,ha", kind: "CY" }
    { code: "TH", name: "Thailand", cont: "AS", cur: "THB", 'cur-name': "Baht", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "th,en", kind: "CY" }
    { code: "TJ", name: "Tajikistan", cont: "AS", cur: "TJS", 'cur-name': "Somoni", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "tg,ru", kind: "CY" }
    { code: "TK", name: "Tokelau", cont: "OC", cur: "NZD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "tkl,en-TK", kind: "CY" }
    { code: "TL", name: "East Timor", cont: "OC", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "tet,pt-TL,id,en", kind: "CY" }
    { code: "TM", name: "Turkmenistan", cont: "AS", cur: "TMT", 'cur-name': "Manat", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "tk,ru,uz", kind: "CY" }
    { code: "TN", name: "Tunisia", cont: "AF", cur: "TND", 'cur-name': "Dinar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "ar-TN,fr", kind: "CY" }
    { code: "TO", name: "Tonga", cont: "OC", cur: "TOP", 'cur-name': "Pa'anga", 'zip-fmt': "", 'zip-rx': "", langs: "to,en-TO", kind: "CY" }
    { code: "TR", name: "Turkey", cont: "AS", cur: "TRY", 'cur-name': "Lira", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "tr-TR,ku,diq,az,av", kind: "CY" }
    { code: "TT", name: "Trinidad and Tobago", cont: "NA", cur: "TTD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-TT,hns,fr,es,zh", kind: "CY" }
    { code: "TV", name: "Tuvalu", cont: "OC", cur: "AUD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "tvl,en,sm,gil", kind: "CY" }
    { code: "TW", name: "Taiwan", cont: "AS", cur: "TWD", 'cur-name': "Dollar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "zh-TW,zh,nan,hak", kind: "CY" }
    { code: "TZ", name: "Tanzania", cont: "AF", cur: "TZS", 'cur-name': "Shilling", 'zip-fmt': "", 'zip-rx': "", langs: "sw-TZ,en,ar", kind: "CY" }
    { code: "UA", name: "Ukraine", cont: "EU", cur: "UAH", 'cur-name': "Hryvnia", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "uk,ru-UA,rom,pl,hu", kind: "CY" }
    { code: "UG", name: "Uganda", cont: "AF", cur: "UGX", 'cur-name': "Shilling", 'zip-fmt': "", 'zip-rx': "", langs: "en-UG,lg,sw,ar", kind: "CY" }
    { code: "UM", name: "United States Minor Outlying Islands", cont: "OC", cur: "USD", 'cur-name': "Dollar ", 'zip-fmt': "", 'zip-rx': "", langs: "en-UM", kind: "CY" }
    { code: "US", name: "United States", cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "#####-####", 'zip-rx': "^\d{5}(-\d{4})?$", langs: "en-US,es-US,haw,fr", kind: "CY" }
    { code: "UY", name: "Uruguay", cont: "SA", cur: "UYU", 'cur-name': "Peso", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "es-UY", kind: "CY" }
    { code: "UZ", name: "Uzbekistan", cont: "AS", cur: "UZS", 'cur-name': "Som", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "uz,ru,tg", kind: "CY" }
    { code: "VA", name: "Vatican", cont: "EU", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "la,it,fr", kind: "CY" }
    { code: "VC", name: "Saint Vincent and the Grenadines", cont: "NA", cur: "XCD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-VC,fr", kind: "CY" }
    { code: "VE", name: "Venezuela", cont: "SA", cur: "VEF", 'cur-name': "Bolivar", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "es-VE", kind: "CY" }
    { code: "VG", name: "British Virgin Islands", cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-VG", kind: "CY" }
    { code: "VI", name: "U.S. Virgin Islands", cont: "NA", cur: "USD", 'cur-name': "Dollar", 'zip-fmt': "#####-####", 'zip-rx': "^\d{5}(-\d{4})?$", langs: "en-VI", kind: "CY" }
    { code: "VN", name: "Vietnam", cont: "AS", cur: "VND", 'cur-name': "Dong", 'zip-fmt': "######", 'zip-rx': "^(\d{6})$", langs: "vi,en,fr,zh,km", kind: "CY" }
    { code: "VU", name: "Vanuatu", cont: "OC", cur: "VUV", 'cur-name': "Vatu", 'zip-fmt': "", 'zip-rx': "", langs: "bi,en-VU,fr-VU", kind: "CY" }
    { code: "WF", name: "Wallis and Futuna", cont: "OC", cur: "XPF", 'cur-name': "Franc", 'zip-fmt': "#####", 'zip-rx': "^(986\d{2})$", langs: "wls,fud,fr-WF", kind: "CY" }
    { code: "WS", name: "Samoa", cont: "OC", cur: "WST", 'cur-name': "Tala", 'zip-fmt': "", 'zip-rx': "", langs: "sm,en-WS", kind: "CY" }
    { code: "YE", name: "Yemen", cont: "AS", cur: "YER", 'cur-name': "Rial", 'zip-fmt': "", 'zip-rx': "", langs: "ar-YE", kind: "CY" }
    { code: "YT", name: "Mayotte", cont: "AF", cur: "EUR", 'cur-name': "Euro", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "fr-YT", kind: "CY" }
    { code: "ZA", name: "South Africa", cont: "AF", cur: "ZAR", 'cur-name': "Rand", 'zip-fmt': "####", 'zip-rx': "^(\d{4})$", langs: "zu,xh,af,nso,en-ZA,tn,st,ts,ss,ve,nr", kind: "CY" }
    { code: "ZM", name: "Zambia", cont: "AF", cur: "ZMK", 'cur-name': "Kwacha", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "en-ZM,bem,loz,lun,lue,ny,toi", kind: "CY" }
    { code: "ZW", name: "Zimbabwe", cont: "AF", cur: "ZWL", 'cur-name': "Dollar", 'zip-fmt': "", 'zip-rx': "", langs: "en-ZW,sn,nr,nd", kind: "CY" }
    { code: "CS", name: "Serbia and Montenegro", cont: "EU", cur: "RSD", 'cur-name': "Dinar", 'zip-fmt': "#####", 'zip-rx': "^(\d{5})$", langs: "cu,hu,sq,sr", kind: "CY" }
    { code: "AN", name: "Netherlands Antilles", cont: "NA", cur: "ANG", 'cur-name': "Guilder", 'zip-fmt': "", 'zip-rx': "", langs: "nl-AN,en,es", kind: "CY" }

    # Timezones
    
    { name: "Africa-Abidjan", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Accra", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Addis_Ababa", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Algiers", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Asmara", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Bamako", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Bangui", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Banjul", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Bissau", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Blantyre", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Brazzaville", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Bujumbura", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Cairo", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Africa-Casablanca", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Ceuta", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Africa-Conakry", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Dakar", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Dar_es_Salaam", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Djibouti", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Douala", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-El_Aaiun", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Freetown", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Gaborone", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Harare", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Johannesburg", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Kampala", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Khartoum", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Kigali", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Kinshasa", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Lagos", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Libreville", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Lome", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Luanda", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Lubumbashi", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Lusaka", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Malabo", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Maputo", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Maseru", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Mbabane", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Mogadishu", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Monrovia", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Nairobi", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Africa-Ndjamena", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Niamey", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Nouakchott", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Ouagadougou", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Porto-Novo", dst: 1, gmt: 1, kind: "TZ" },
    { name: "Africa-Sao_Tome", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Africa-Tripoli", dst: 2, gmt: 2, kind: "TZ" },
    { name: "Africa-Tunis", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Africa-Windhoek", dst: 1, gmt: 2, kind: "TZ" },
    { name: "America-Adak", dst: -9, gmt: -10, kind: "TZ" },
    { name: "America-Anchorage", dst: -8, gmt: -9, kind: "TZ" },
    { name: "America-Anguilla", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Antigua", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Araguaina", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Buenos_Aires", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Catamarca", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Cordoba", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Jujuy", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-La_Rioja", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Mendoza", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Rio_Gallegos", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Salta", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-San_Juan", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-San_Luis", dst: -4, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Tucuman", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Argentina-Ushuaia", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Aruba", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Asuncion", dst: -4, gmt: -3, kind: "TZ" },
    { name: "America-Atikokan", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Bahia", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Barbados", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Belem", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Belize", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Blanc-Sablon", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Boa_Vista", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Bogota", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Boise", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Cambridge_Bay", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Campo_Grande", dst: -4, gmt: -3, kind: "TZ" },
    { name: "America-Cancun", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Caracas", dst: "-4.5", gmt: "-4.5", kind: "TZ" },
    { name: "America-Cayenne", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Cayman", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Chicago", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Chihuahua", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Costa_Rica", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Cuiaba", dst: -4, gmt: -3, kind: "TZ" },
    { name: "America-Curacao", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Danmarkshavn", dst: 0, gmt: 0, kind: "TZ" },
    { name: "America-Dawson", dst: -7, gmt: -8, kind: "TZ" },
    { name: "America-Dawson_Creek", dst: -7, gmt: -7, kind: "TZ" },
    { name: "America-Denver", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Detroit", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Dominica", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Edmonton", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Eirunepe", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-El_Salvador", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Fortaleza", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Glace_Bay", dst: -3, gmt: -4, kind: "TZ" },
    { name: "America-Godthab", dst: -2, gmt: -3, kind: "TZ" },
    { name: "America-Goose_Bay", dst: -3, gmt: -4, kind: "TZ" },
    { name: "America-Grand_Turk", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Grenada", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Guadeloupe", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Guatemala", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Guayaquil", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Guyana", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Halifax", dst: -3, gmt: -4, kind: "TZ" },
    { name: "America-Havana", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Hermosillo", dst: -7, gmt: -7, kind: "TZ" },
    { name: "America-Indiana-Indianapolis", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Indiana-Knox", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Indiana-Marengo", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Indiana-Petersburg", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Indiana-Tell_City", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Indiana-Vevay", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Indiana-Vincennes", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Indiana-Winamac", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Inuvik", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Iqaluit", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Jamaica", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Juneau", dst: -8, gmt: -9, kind: "TZ" },
    { name: "America-Kentucky-Louisville", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Kentucky-Monticello", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-La_Paz", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Lima", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Los_Angeles", dst: -7, gmt: -8, kind: "TZ" },
    { name: "America-Maceio", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Managua", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Manaus", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Marigot", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Martinique", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Matamoros", dst: 0, gmt: 0, kind: "TZ" },
    { name: "America-Mazatlan", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-Menominee", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Merida", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Mexico_City", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Miquelon", dst: -2, gmt: -3, kind: "TZ" },
    { name: "America-Moncton", dst: -3, gmt: -4, kind: "TZ" },
    { name: "America-Monterrey", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Montevideo", dst: -3, gmt: -2, kind: "TZ" },
    { name: "America-Montreal", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Montserrat", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Nassau", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-New_York", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Nipigon", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Nome", dst: -8, gmt: -9, kind: "TZ" },
    { name: "America-Noronha", dst: -2, gmt: -2, kind: "TZ" },
    { name: "America-North_Dakota-Center", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-North_Dakota-New_Salem", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Ojinaga", dst: 0, gmt: 0, kind: "TZ" },
    { name: "America-Panama", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Pangnirtung", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Paramaribo", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Phoenix", dst: -7, gmt: -7, kind: "TZ" },
    { name: "America-Port-au-Prince", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Port_of_Spain", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Porto_Velho", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Puerto_Rico", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Rainy_River", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Rankin_Inlet", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Recife", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Regina", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Resolute", dst: -5, gmt: -5, kind: "TZ" },
    { name: "America-Rio_Branco", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Santa_Isabel", dst: 0, gmt: 0, kind: "TZ" },
    { name: "America-Santarem", dst: -3, gmt: -3, kind: "TZ" },
    { name: "America-Santiago", dst: -4, gmt: -3, kind: "TZ" },
    { name: "America-Santo_Domingo", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Sao_Paulo", dst: -3, gmt: -2, kind: "TZ" },
    { name: "America-Scoresbysund", dst: 0, gmt: -1, kind: "TZ" },
    { name: "America-Shiprock", dst: -6, gmt: -7, kind: "TZ" },
    { name: "America-St_Barthelemy", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-St_Johns", dst: "-2.5", gmt: "-3.5", kind: "TZ" },
    { name: "America-St_Kitts", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-St_Lucia", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-St_Thomas", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-St_Vincent", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Swift_Current", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Tegucigalpa", dst: -6, gmt: -6, kind: "TZ" },
    { name: "America-Thule", dst: -3, gmt: -4, kind: "TZ" },
    { name: "America-Thunder_Bay", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Tijuana", dst: -7, gmt: -8, kind: "TZ" },
    { name: "America-Toronto", dst: -4, gmt: -5, kind: "TZ" },
    { name: "America-Tortola", dst: -4, gmt: -4, kind: "TZ" },
    { name: "America-Vancouver", dst: -7, gmt: -8, kind: "TZ" },
    { name: "America-Whitehorse", dst: -7, gmt: -8, kind: "TZ" },
    { name: "America-Winnipeg", dst: -5, gmt: -6, kind: "TZ" },
    { name: "America-Yakutat", dst: -8, gmt: -9, kind: "TZ" },
    { name: "America-Yellowknife", dst: -6, gmt: -7, kind: "TZ" },
    { name: "Antarctica-Casey", dst: 11, gmt: 11, kind: "TZ" },
    { name: "Antarctica-Davis", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Antarctica-DumontDUrville", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Antarctica-Mawson", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Antarctica-McMurdo", dst: 12, gmt: 13, kind: "TZ" },
    { name: "Antarctica-Palmer", dst: -4, gmt: -3, kind: "TZ" },
    { name: "Antarctica-Rothera", dst: -3, gmt: -3, kind: "TZ" },
    { name: "Antarctica-South_Pole", dst: 12, gmt: 13, kind: "TZ" },
    { name: "Antarctica-Syowa", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Antarctica-Vostok", dst: 6, gmt: 6, kind: "TZ" },
    { name: "Arctic-Longyearbyen", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Asia-Aden", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Asia-Almaty", dst: 6, gmt: 6, kind: "TZ" },
    { name: "Asia-Amman", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Asia-Anadyr", dst: 13, gmt: 12, kind: "TZ" },
    { name: "Asia-Aqtau", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Aqtobe", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Ashgabat", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Baghdad", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Asia-Bahrain", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Asia-Baku", dst: 5, gmt: 4, kind: "TZ" },
    { name: "Asia-Bangkok", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Beirut", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Asia-Bishkek", dst: 6, gmt: 6, kind: "TZ" },
    { name: "Asia-Brunei", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Choibalsan", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Chongqing", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Colombo", dst: "5.5", gmt: "5.5", kind: "TZ" },
    { name: "Asia-Damascus", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Asia-Dhaka", dst: 7, gmt: 6, kind: "TZ" },
    { name: "Asia-Dili", dst: 9, gmt: 9, kind: "TZ" },
    { name: "Asia-Dubai", dst: 4, gmt: 4, kind: "TZ" },
    { name: "Asia-Dushanbe", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Gaza", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Asia-Harbin", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Ho_Chi_Minh", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Hong_Kong", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Hovd", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Irkutsk", dst: 9, gmt: 8, kind: "TZ" },
    { name: "Asia-Jakarta", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Jayapura", dst: 9, gmt: 9, kind: "TZ" },
    { name: "Asia-Jerusalem", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Asia-Kabul", dst: "4.5", gmt: "4.5", kind: "TZ" },
    { name: "Asia-Kamchatka", dst: 13, gmt: 12, kind: "TZ" },
    { name: "Asia-Karachi", dst: 6, gmt: 5, kind: "TZ" },
    { name: "Asia-Kashgar", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Kathmandu", dst: "5.75", gmt: "5.75", kind: "TZ" },
    { name: "Asia-Kolkata", dst: "5.5", gmt: "5.5", kind: "TZ" },
    { name: "Asia-Krasnoyarsk", dst: 8, gmt: 7, kind: "TZ" },
    { name: "Asia-Kuala_Lumpur", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Kuching", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Kuwait", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Asia-Macau", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Magadan", dst: 12, gmt: 11, kind: "TZ" },
    { name: "Asia-Makassar", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Manila", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Muscat", dst: 4, gmt: 4, kind: "TZ" },
    { name: "Asia-Nicosia", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Asia-Novokuznetsk", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Novosibirsk", dst: 7, gmt: 6, kind: "TZ" },
    { name: "Asia-Omsk", dst: 7, gmt: 6, kind: "TZ" },
    { name: "Asia-Oral", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Phnom_Penh", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Pontianak", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Pyongyang", dst: 9, gmt: 9, kind: "TZ" },
    { name: "Asia-Qatar", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Asia-Qyzylorda", dst: 6, gmt: 6, kind: "TZ" },
    { name: "Asia-Rangoon", dst: "6.5", gmt: "6.5", kind: "TZ" },
    { name: "Asia-Riyadh", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Asia-Sakhalin", dst: 11, gmt: 10, kind: "TZ" },
    { name: "Asia-Samarkand", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Seoul", dst: 9, gmt: 9, kind: "TZ" },
    { name: "Asia-Shanghai", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Singapore", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Taipei", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Tashkent", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Asia-Tbilisi", dst: 4, gmt: 4, kind: "TZ" },
    { name: "Asia-Tehran", dst: "4.5", gmt: "3.5", kind: "TZ" },
    { name: "Asia-Thimphu", dst: 6, gmt: 6, kind: "TZ" },
    { name: "Asia-Tokyo", dst: 9, gmt: 9, kind: "TZ" },
    { name: "Asia-Ulaanbaatar", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Urumqi", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Asia-Vientiane", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Asia-Vladivostok", dst: 11, gmt: 10, kind: "TZ" },
    { name: "Asia-Yakutsk", dst: 10, gmt: 9, kind: "TZ" },
    { name: "Asia-Yekaterinburg", dst: 6, gmt: 5, kind: "TZ" },
    { name: "Asia-Yerevan", dst: 5, gmt: 4, kind: "TZ" },
    { name: "Atlantic-Azores", dst: 0, gmt: -1, kind: "TZ" },
    { name: "Atlantic-Bermuda", dst: -3, gmt: -4, kind: "TZ" },
    { name: "Atlantic-Canary", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Atlantic-Cape_Verde", dst: -1, gmt: -1, kind: "TZ" },
    { name: "Atlantic-Faroe", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Atlantic-Madeira", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Atlantic-Reykjavik", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Atlantic-South_Georgia", dst: -2, gmt: -2, kind: "TZ" },
    { name: "Atlantic-St_Helena", dst: 0, gmt: 0, kind: "TZ" },
    { name: "Atlantic-Stanley", dst: -4, gmt: -3, kind: "TZ" },
    { name: "Australia-Adelaide", dst: "9.5", gmt: "10.5", kind: "TZ" },
    { name: "Australia-Brisbane", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Australia-Broken_Hill", dst: "9.5", gmt: "10.5", kind: "TZ" },
    { name: "Australia-Currie", dst: 10, gmt: 11, kind: "TZ" },
    { name: "Australia-Darwin", dst: "9.5", gmt: "9.5", kind: "TZ" },
    { name: "Australia-Eucla", dst: "8.75", gmt: "8.75", kind: "TZ" },
    { name: "Australia-Hobart", dst: 10, gmt: 11, kind: "TZ" },
    { name: "Australia-Lindeman", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Australia-Lord_Howe", dst: "10.5", gmt: 11, kind: "TZ" },
    { name: "Australia-Melbourne", dst: 10, gmt: 11, kind: "TZ" },
    { name: "Australia-Perth", dst: 8, gmt: 8, kind: "TZ" },
    { name: "Australia-Sydney", dst: 10, gmt: 11, kind: "TZ" },
    { name: "Europe-Amsterdam", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Andorra", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Athens", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Belgrade", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Berlin", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Bratislava", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Brussels", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Bucharest", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Budapest", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Chisinau", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Copenhagen", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Dublin", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Europe-Gibraltar", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Guernsey", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Europe-Helsinki", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Isle_of_Man", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Europe-Istanbul", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Jersey", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Europe-Kaliningrad", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Kiev", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Lisbon", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Europe-Ljubljana", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-London", dst: 1, gmt: 0, kind: "TZ" },
    { name: "Europe-Luxembourg", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Madrid", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Malta", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Mariehamn", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Minsk", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Monaco", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Moscow", dst: 4, gmt: 3, kind: "TZ" },
    { name: "Europe-Oslo", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Paris", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Podgorica", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Prague", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Riga", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Rome", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Samara", dst: 5, gmt: 4, kind: "TZ" },
    { name: "Europe-San_Marino", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Sarajevo", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Simferopol", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Skopje", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Sofia", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Stockholm", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Tallinn", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Tirane", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Uzhgorod", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Vaduz", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Vatican", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Vienna", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Vilnius", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Volgograd", dst: 4, gmt: 3, kind: "TZ" },
    { name: "Europe-Warsaw", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Zagreb", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Europe-Zaporozhye", dst: 3, gmt: 2, kind: "TZ" },
    { name: "Europe-Zurich", dst: 2, gmt: 1, kind: "TZ" },
    { name: "Indian-Antananarivo", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Indian-Chagos", dst: 6, gmt: 6, kind: "TZ" },
    { name: "Indian-Christmas", dst: 7, gmt: 7, kind: "TZ" },
    { name: "Indian-Cocos", dst: "6.5", gmt: "6.5", kind: "TZ" },
    { name: "Indian-Comoro", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Indian-Kerguelen", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Indian-Mahe", dst: 4, gmt: 4, kind: "TZ" },
    { name: "Indian-Maldives", dst: 5, gmt: 5, kind: "TZ" },
    { name: "Indian-Mauritius", dst: 4, gmt: 4, kind: "TZ" },
    { name: "Indian-Mayotte", dst: 3, gmt: 3, kind: "TZ" },
    { name: "Indian-Reunion", dst: 4, gmt: 4, kind: "TZ" },
    { name: "Pacific-Apia", dst: -11, gmt: -10, kind: "TZ" },
    { name: "Pacific-Auckland", dst: 12, gmt: 13, kind: "TZ" },
    { name: "Pacific-Chatham", dst: "12.75", gmt: "13.75", kind: "TZ" },
    { name: "Pacific-Easter", dst: -6, gmt: -5, kind: "TZ" },
    { name: "Pacific-Efate", dst: 11, gmt: 11, kind: "TZ" },
    { name: "Pacific-Enderbury", dst: 13, gmt: 13, kind: "TZ" },
    { name: "Pacific-Fakaofo", dst: -10, gmt: -10, kind: "TZ" },
    { name: "Pacific-Fiji", dst: 12, gmt: 13, kind: "TZ" },
    { name: "Pacific-Funafuti", dst: 12, gmt: 12, kind: "TZ" },
    { name: "Pacific-Galapagos", dst: -6, gmt: -6, kind: "TZ" },
    { name: "Pacific-Gambier", dst: -9, gmt: -9, kind: "TZ" },
    { name: "Pacific-Guadalcanal", dst: 11, gmt: 11, kind: "TZ" },
    { name: "Pacific-Guam", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Pacific-Honolulu", dst: -10, gmt: -10, kind: "TZ" },
    { name: "Pacific-Johnston", dst: -10, gmt: -10, kind: "TZ" },
    { name: "Pacific-Kiritimati", dst: 14, gmt: 14, kind: "TZ" },
    { name: "Pacific-Kosrae", dst: 11, gmt: 11, kind: "TZ" },
    { name: "Pacific-Kwajalein", dst: 12, gmt: 12, kind: "TZ" },
    { name: "Pacific-Majuro", dst: 12, gmt: 12, kind: "TZ" },
    { name: "Pacific-Marquesas", dst: "-9.5", gmt: "-9.5", kind: "TZ" },
    { name: "Pacific-Midway", dst: -11, gmt: -11, kind: "TZ" },
    { name: "Pacific-Nauru", dst: 12, gmt: 12, kind: "TZ" },
    { name: "Pacific-Niue", dst: -11, gmt: -11, kind: "TZ" },
    { name: "Pacific-Norfolk", dst: "11.5", gmt: "11.5", kind: "TZ" },
    { name: "Pacific-Noumea", dst: 11, gmt: 11, kind: "TZ" },
    { name: "Pacific-Pago_Pago", dst: -11, gmt: -11, kind: "TZ" },
    { name: "Pacific-Palau", dst: 9, gmt: 9, kind: "TZ" },
    { name: "Pacific-Pitcairn", dst: -8, gmt: -8, kind: "TZ" },
    { name: "Pacific-Ponape", dst: 11, gmt: 11, kind: "TZ" },
    { name: "Pacific-Port_Moresby", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Pacific-Rarotonga", dst: -10, gmt: -10, kind: "TZ" },
    { name: "Pacific-Saipan", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Pacific-Tahiti", dst: -10, gmt: -10, kind: "TZ" },
    { name: "Pacific-Tarawa", dst: 12, gmt: 12, kind: "TZ" },
    { name: "Pacific-Tongatapu", dst: 13, gmt: 13, kind: "TZ" },
    { name: "Pacific-Truk", dst: 10, gmt: 10, kind: "TZ" },
    { name: "Pacific-Wake", dst: 12, gmt: 12, kind: "TZ" },
    { name: "Pacific-Wallis", dst: 12, gmt: 12, kind: "TZ" }
  ]

  N = mongoose.model('Geo')

  N.remove({}, (err) ->
    for d in data
      N.create(d)
  )
, 1000)
