import Foundation

extension ActivityLabels {
    
    static func RandomGymGreeting() -> String {
        let greetings = [
            "Welcome back, champ!",
            "Let’s crush it today",
            "Time to lift some spirits!",
            "You’re looking strong!",
            "Back for more gains?",
            "Let’s get pumped!",
            "Grind time!",
            "Ready to sweat?",
            "Another day, another PR!",
            "Fuel the hustle",
            "Let’s make it count!",
            "Your goals await!",
            "Strength starts here.",
            "Let’s go, beast mode!",
            "Flex those goals!",
            "Good to see you again!",
            "Make today your best set!",
            "Earn those gains!",
            "Time to move mountains!",
            "Push. Lift. Repeat."
        ]
        
        return greetings.randomElement() ?? "Welcome back!"
    }

    static func getRandomGymPun() -> String {
        let puns = [
            "No pain, no champagne",
            "Gym and tonic",
            "Beast mode: activated",
            "Do you even lift, brotein?",
            "Flex appeal",
            "Gains and glory",
            "Swole patrol",
            "Lift happens",
            "Gymspirational",
            "Gympossible",
            "The grind never skips leg day",
            "Barbellieve in yourself",
            "Reps for Jesus",
            "Squat goals",
            "Ripped and ready",
            "Abs-olutely",
            "Grip it and rip it",
            "Protein shake it off",
            "Lettuce get swole",
            "Broccoli and barbells",
            "Avocardio",
            "Carb diem",
            "Cereal lifter",
            "Flexitarian",
            "Gym and juice",
            "Just one more rep-pea",
            "Squat it like it’s hot",
            "Deadlifts and chill",
            "Bench better have my spot",
            "Core values",
            "Lunge and prosper",
            "Push-up or shut up",
            "Triceps don’t lie",
            "Ab-solute legend",
            "Stretch goals",
            "Dumbbell in disguise",
            "Curl power",
            "Treadmill of life",
            "Sore today, strong tomorrow",
            "Will squat for pizza",
            "Train insane or remain the same",
            "Wake, gym, repeat",
            "Fit to be tried",
            "Gymtimidation? Never heard of her",
            "Every day I’m muscle’n",
            "You can’t spell challenge without change",
            "Rest is part of the rep",
            "You had me at “spot me”",
            "We’ve got good chemistry — mostly creatine",
            "My love for you is unbreakable… unlike my PR",
            "I’m totally ab-sessed with you",
            "You’re the whey to my heart",
            "We’re a perfect set",
            "Gymfinity and beyond",
            "Flexecution",
            "Lift-off!",
            "Gainnado",
            "Buffstuff",
            "Irony (the study of iron)",
            "The Republic",
            "Swole mate",
            "Dumbbelievable",
            "Gainbow (after a good pump)",
            "Lactic acid trip",
            "The muscle hustle",
            "Fit-nomenal",
            "Rep-a-roni",
            "Cardio party-o"
        ]

        return puns.randomElement() ?? "Keep pushing!"
    }
    
    static func GenerateTitle(name: String?) -> String {
        var titles: [String] = []
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let weekday = calendar.weekdaySymbols[calendar.component(.weekday, from: now) - 1]
        
        // Personalized greetings
        if let name = name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            titles.append("Hello, \(name)")
            titles.append("Welcome back, \(name)")
            titles.append("Ready for another session, \(name)?")
        }
        
        // Time-based greetings
        if hour < 12 {
            titles.append("Good morning")
        } else if hour < 18 {
            titles.append("Good afternoon")
        } else {
            titles.append("Good evening")
        }
        
        // Day-based greeting
        titles.append("Happy \(weekday)")
        
        // Generic motivational/greeting combinations
        titles += [
            "Welcome back",
            "Let's get started",
            "Time to recap",
            "Jump back in",
            "Ready to train?",
            "Let’s hit your goals",
            "Pick up where you left off",
            "Keep the momentum going",
            "Your progress awaits",
            "New session, new gains"
        ]
        
        return titles.randomElement()!
    }

    
}
