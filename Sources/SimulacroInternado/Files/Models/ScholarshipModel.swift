import Vapor

enum ScholarshipModel: String, Content {
    case federal = "Federal"
    case statal = "Estatal"
    case schoolar = "Escolar"
    case institutional = "Institucional"
    case worker = "Trabajador"
    case none = "Ninguna"
}
