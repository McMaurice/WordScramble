//
//  ContentView.swift
//  WordScramble
//
//  Created by Macmaurice Osuji on 2/22/23.
//

import SwiftUI

struct ContentView: View {
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var usedWord = [String]()
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMassage = ""
    @State private var showingError = false
    @FocusState private var isFocused: Bool

    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Earn one point for every letter in your word.")
                    .italic()
                    .padding(.top)
                
                VStack(alignment: .leading) {
                    TextField("Enter your word...", text: $newWord)
                        .autocapitalization(.none)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(25)
                        .focused($isFocused)
                        
                }
                .padding()
                Button(action: {
                    addNewWord()
                }) {
                    Text("Submit")
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(25)
                }

                VStack {
                    List {
                        ForEach(usedWord, id: \.self) { word in
                            HStack {
                               // Image(systemName: "\(word.count).circle")
                                Text(word)
                                Spacer()
                                Text("\(word.count) Point")
                                    .foregroundColor(.green)
                            }
                            .font(.callout)
                        }
                    }
                }
                Text("Your current score is \(score)")
                    .font(.headline)
                
                
            }
            .navigationTitle(rootWord.uppercased())
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button("New Word", action: startGame)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMassage)
            }
            .onAppear {
                isFocused = true
            }
            
        }
        
    }///
    
    func addNewWord() {
        
        let ans = newWord.components(separatedBy: CharacterSet.symbols).joined().lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard ans.count > 2 else {
            wordError(title: "To Short!", message: "Try again!")
            return
        }
        
        guard isOriginal(word: ans) else {
            wordError(title: "Word alredy used!", message: "Oops! Try again")
            return
        }
        guard isPossible(word: ans) else {
            wordError(title: "Word not Possible", message: "You can't spell \(ans) form '\(rootWord.uppercased())'!")
            return
        }
        guard isReal(word: ans) else {
            wordError(title: "Word not recognized", message: "You can't just make up a word!")
            return
        }
        guard isSameWord(word: ans) else {
            wordError(title: "This is the given Word", message: "Think outside the box!")
            return
        }
        
        withAnimation {
            usedWord.insert(ans, at: 0)
        }
        score += ans.count
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWord = [String]()
                score = 0
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func isSameWord (word: String) -> Bool {
        if word == rootWord {
            return false
        }
        return true
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let character = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: character)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missSpelledReange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return missSpelledReange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMassage = message
        showingError = true
    }
    
}///

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
