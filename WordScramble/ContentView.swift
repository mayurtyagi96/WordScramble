//
//  ContentView.swift
//  WordScramble
//
//  Created by Mayur on 18/07/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("Score").font(.headline)){
                    Text("\(usedWords.count)")
                }
                
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section{
                    ForEach(usedWords, id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                    
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addWord()
            }
            .onAppear(perform: {
                getRootWord()
            })
            .alert(alertTitle, isPresented: $showAlert) {} message: {
                Text(alertMsg)
            }
            .toolbar{
                Button("Restart", action: getRootWord)
            }
        }
    }
    
    func addWord(){
        let word = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard word.count > 0 else{ return }
        guard isOriginal(word: word) else{
            showError(title: "Duplicate", message: "Be more original")
            return
        }
        guard isContainLetter(word: word) else{
            showError(title: "Letter error", message: "You can spell this from \(rootWord)")
            return
        }
        guard isSpellPossible(word: word) else{
            showError(title: "spell Error`", message: "this word spell is wrong")
            return
        }
        guard tooShort(word: word) else{
            showError(title: "too short", message: "word is less than 3 letters or is root word")
            return
        }
            
        withAnimation{
            usedWords.insert(word, at: 0)
        }
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isContainLetter(word: String) -> Bool{
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isSpellPossible(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misSpelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misSpelledRange.location == NSNotFound
    }
    
    func tooShort(word: String) -> Bool{
        guard word.count > 2 else{
            return false
        }
        guard word != rootWord else{
            return false
        }
        return true
    }
    
    func showError(title: String, message: String){
        alertTitle = title
        alertMsg = message
        showAlert = true
    }
    
    func getRootWord(){
        if let txtFileUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let content = try? String(contentsOf: txtFileUrl){
                let words = content.components(separatedBy: .newlines)
                rootWord = words.randomElement() ?? "renaming"
                usedWords = []
                newWord = ""
                return
            }
        }
        fatalError("could not founsd the file")
    }
}

#Preview {
    ContentView()
}
