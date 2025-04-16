
enum OnboardingStep {
    case welcome
    case mixMusic
    case selectSkill
    case finale
}

enum DJSkillLevel: String, CaseIterable {
    case beginner = "I'm new to DJing"
    case someExperience = "I’ve tried DJ apps before"
    case pro = "I’m a professional DJ"
}
