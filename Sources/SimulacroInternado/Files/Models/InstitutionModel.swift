import Vapor

enum InstitutionModel: String, Content {
    case imss = "IMSS"
    case issste = "ISSSTE"
    case ssa = "SSA"
    case imb = "IMB"
    case other = "OTRO"
}
