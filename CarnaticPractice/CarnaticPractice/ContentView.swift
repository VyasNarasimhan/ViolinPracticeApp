//  ContentView.swift
//  CarnaticPractice
//  Created by Vyas Narasimhan and Kaushik Narasimhan on 4/23/20.
//  Copyright © 2020 Vyas Narasimhan and Kaushik Narasimhan. All rights reserved.
import SwiftUI

struct Song: Hashable {
    var songname: String
    var color: Color
    var message: String
    var date: String
    var dayssince: Int
    var ragam: String
    var composer: String
    var display: String
}

class AllSongs: ObservableObject {
    @Published var allsongs = loadFile()
    @Published var datesToPractice = getFile(name: "Dates")
}

struct ColorManager {
    static let subtleRed = Color("SubtleRed")
    static let subtleYellow = Color("SubtleYellow")
    static let subtleGreen = Color("SubtleGreen")
    static let subtleBlue = Color("SubtleBlue")
}
func getFile(name: String) -> [String] {
    var temp: [String] = []
    var saved: Data
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        let fileURL = documentsDirectory.appendingPathComponent(name + ".txt")
        let exists = FileManager().fileExists(atPath: fileURL.path)
        if exists == true {
            do {
                saved = try Data(contentsOf: fileURL)
                let hello = String(data: saved, encoding: .utf8)
                temp = hello!.components(separatedBy: "\n")
            } catch let e {
                print(e.localizedDescription)
            }
        } else {
            if let filepath = Bundle.main.path(forResource: name, ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath)
                    do {
                        try contents.write(to: fileURL, atomically: false, encoding: .utf8)
                        saved = try Data(contentsOf: fileURL)
                        let the = String(data: saved, encoding: .utf8)
                            temp = the!.components(separatedBy: "\n")
                    } catch let e {
                        print(e.localizedDescription)
                    }
                } catch let f {
                        print(f.localizedDescription)
                }
            }
        }
    }
    return temp
}
func loadFile() -> [[Song]] {
    var all: [[Song]] = []
    let temp: [String] = getFile(name: "SongsLog")
    var melodies: [Song] = []
    var labels: [String] = []
    var i = 0
    while i < temp.count-1 {
        if !temp[i].contains("|") && temp[i] != "" {
            labels.append(temp[i])
            if melodies.count > 0 {
                all.append(melodies)
            }
            melodies = []
        } else {
            let tempdate = temp[i].components(separatedBy: "|")
            if tempdate.count > 1 {
                melodies.append(Song(songname: temp[i], color: color(songs3: temp[i]), message: "Days since last played: \(daysSince(songs1: temp[i]))", date: tempdate[1], dayssince: daysSince(songs1: temp[i]), ragam: tempdate[3], composer: tempdate[2], display: tempdate[0]))
            }
        }
        if i == temp.count-2 {
            all.append(melodies)
        }
        i += 1
    }
    for i in 0..<all.count {
        all[i].sort{$0.dayssince > $1.dayssince}
    }
    return all
}

func loadLabels() -> [String] {
    let temp: [String] = getFile(name: "SongsLog")
    var labels: [String] = []
    var i = 0
    while i < temp.count-1 {
        if !temp[i].contains("|") && temp[i] != "" {
            labels.append(temp[i])
        }
        i += 1
    }
    return labels
}
func loadRagamsComposers() -> [[String]] {
    let temp: [String] = getFile(name: "SongsLog")
    var all: [[String]] = []
    var temp2: [String] = []
    var ragams: [String] = ["None"]
    var composers: [String] = ["None"]
    var i = 0
    while i < temp.count-1 {
        if temp[i].contains("|") {
            temp2 = temp[i].components(separatedBy: "|")
            if !ragams.contains(temp2[3]) {
                ragams.append(temp2[3])
            }
            if !composers.contains(temp2[2]) {
                composers.append(temp2[2])
            }
        }
        i += 1
    }
    all.append(ragams)
    all.append(composers)
    return all
}
func loadPlayedSongs() -> [[String]] {
    let temp: [String] = getFile(name: "SongsLog")
    var labels: [[String]] = []
    var i = 0
    while i < temp.count-1 {
        if !temp[i].contains("|") && temp[i] != "" {
            labels.append([])
        }
        i += 1
    }
    return labels
}
func color(songs3: String) -> Color {
    let temp = songs3.components(separatedBy: "|")
    if temp.count > 1 {
        let date = temp[1]
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let start: Date = dateFormatter.date(from: date)!
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: now)
        let time = calendar.dateComponents([.day], from: date1, to: date2)
        let time1 = time.day
        if time1! < 7 {
            return ColorManager.subtleGreen
        } else if time1! < 14 {
            return ColorManager.subtleYellow
        } else if time1! < 21 {
            return Color.orange
        } else {
            return ColorManager.subtleRed
        }
    } else {
        return Color.white
    }
}
func daysSince(songs1: String) -> Int {
    let temp = songs1.components(separatedBy: "|")
    if temp.count > 1 {
        let date = temp[1]
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let start: Date = dateFormatter.date(from: date)!
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: now)
        let time = calendar.dateComponents([.day], from: date1, to: date2)
        return time.day!
    } else {
        return 0
    }
}
func exactSong(songs2: String) -> String {
    let temp = songs2.components(separatedBy: "|")
    return temp[0]
}
func change(song: String, date: String) {
    var temp: [String] = []
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
        do {
            let saved = try Data(contentsOf: fileURL)
            let hello = String(data: saved, encoding: .utf8)
            temp = hello!.components(separatedBy: "\n")
            var counter = 0
            while counter < temp.count-1 {
                let the = temp[counter].components(separatedBy: "|")
                if song == the[0] {
                    temp[counter] = the[0] + "|" + date + "|" + the[2] + "|" + the[3]
                    break
                }
                counter += 1
            }
            var file = ""
            var thecounter = 0
            while thecounter < temp.count {
                if temp[thecounter].count > 0 {
                    if thecounter == temp.count-1 {
                        file += temp[thecounter]
                    } else {
                        file += temp[thecounter] + "\n"
                    }
                }
                thecounter += 1
            }
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
                let exists = FileManager().fileExists(atPath: fileURL.path)
                if exists == true {
                    do {
                        try file.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch let e {
                        print(e.localizedDescription)
                    }
                }
            }
        } catch {
            print ("contents not loaded")
        }
    } else {
        print ("file not found")
    }
}

func thechange(fullsong: Song, date: String) {
    let thetemp = fullsong.songname.components(separatedBy: "|")
    let songname = thetemp[0]
    change(song: songname, date: date)
}

func addSong(song: String, type: String) {
    var temp: [String] = []
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
        do {
            let saved = try Data(contentsOf: fileURL)
            let hello = String(data: saved, encoding: .utf8)
            temp = hello!.components(separatedBy: "\n")
            for i in 0..<temp.count {
                if temp[i] == type {
                    if i == temp.count-1 {
                        temp.append(song)
                    } else {
                        temp.insert(song, at: i+1)
                    }
                    break
                }
            }
            var file = ""
            for i in temp {
                file += i + "\n"
            }
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
                let exists = FileManager().fileExists(atPath: fileURL.path)
                if exists == true {
                    do {
                        try file.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch let e {
                        print(e.localizedDescription)
                    }
                }
            }
        } catch {
            print ("contents not loaded")
        }
    } else {
        print ("file not found")
    }
}

func deleteSong(songs: [[Song]], labels: [String]) {
    var file = ""
    for i in 0..<labels.count {
        file += labels[i] + "\n"
        for j in songs[i] {
            file += j.songname + "\n"
        }
    }
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
        let exists = FileManager().fileExists(atPath: fileURL.path)
        if exists == true {
            do {
                try file.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch let e {
                print(e.localizedDescription)
            }
        }
    }
}

func addSection(title: String) {
    var temp: [String] = []
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
        do {
            let saved = try Data(contentsOf: fileURL)
            let hello = String(data: saved, encoding: .utf8)
            temp = hello!.components(separatedBy: "\n")
            temp.append(title)
            var file = ""
            for i in temp {
                file += i + "\n"
            }
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                let fileURL = documentsDirectory.appendingPathComponent("SongsLog.txt")
                let exists = FileManager().fileExists(atPath: fileURL.path)
                if exists == true {
                    do {
                        try file.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch let e {
                        print(e.localizedDescription)
                    }
                }
            }
        } catch {
            print ("contents not loaded")
        }
    } else {
        print ("file not found")
    }
}

struct AddNewSong: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var labels: [String]
    @State var showRagams: Bool = false
    @State var showComposers: Bool = false
    @State var newsong = ""
    @State var newragam = ""
    @State var newcomposer = ""
    @EnvironmentObject var allsongs: AllSongs
    var ragams = loadRagamsComposers()[0]
    var composers = loadRagamsComposers()[1]
    var label: String
    var body: some View {
        VStack {
            NavigationView {
                List {
                    TextField("Song name: ", text: self.$newsong)
                    .disableAutocorrection(true)
                    TextField("Song ragam: ", text: self.$newragam)
                        .onTapGesture {
                            self.showRagams.toggle()
                    }
                    .disableAutocorrection(true)
                    if self.showRagams == true {
                        ForEach(self.ragams.filter {self.newragam.isEmpty ? true : $0.contains(self.newragam)}, id: \.self) { item in
                            Text(item)
                                .onTapGesture {
                                    self.newragam = item
                                    self.showRagams.toggle()
                            }
                        }
                    }
                    TextField("Song composer: ", text: self.$newcomposer)
                    .disableAutocorrection(true)
                    .onTapGesture {
                            self.showComposers.toggle()
                    }
                    .disableAutocorrection(true)
                    if self.showComposers == true {
                        ForEach(self.composers.filter {self.newcomposer.isEmpty ? true : $0.contains(self.newcomposer)}, id: \.self) { item in
                            Text(item)
                                .onTapGesture {
                                    self.newcomposer = item
                                    self.showComposers.toggle()
                            }
                        }
                    }
                    Button(action: {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        if self.newragam.count > 0 && self.newsong != "" && self.newragam != "" {
                            addSong(song: self.newsong + "|" + df.string(from: Date()) + "|" + self.newcomposer + "|" + self.newragam, type: self.label)
                            self.allsongs.allsongs[self.labels.firstIndex(of: self.label)!].append(Song(songname: self.newsong + "|" + df.string(from: Date()), color: ColorManager.subtleBlue, message: "Days since last played: 0", date: df.string(from: Date()), dayssince: 0, ragam: self.newragam, composer: self.newcomposer, display: self.newsong))
                            self.newragam = ""
                            self.newsong = ""
                            self.newcomposer = ""
                            self.showComposers = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("Add")
                            .foregroundColor(.blue)
                    })
                }
            }
        }
    }
}

struct PracticeDates: View {
    @EnvironmentObject var allsongs: AllSongs
    @State var dates: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<7, id: \.self) { date in
                    Button(action: {
                        if self.allsongs.datesToPractice.contains(self.dates[date]) {
                            self.allsongs.datesToPractice.removeAll(where: { $0 == self.dates[date] } )
                        } else {
                            self.allsongs.datesToPractice.append(self.dates[date])
                        }
                        self.writeToFile()
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                        center.removeAllPendingNotificationRequests()
                        for date in self.allsongs.datesToPractice {
                            let content = UNMutableNotificationContent()
                            content.subtitle = "Remember to practice today!"
                            content.sound = UNNotificationSound.default
                            var dateComponents = DateComponents()
                            dateComponents.calendar = Calendar.current
                            dateComponents.weekday = (self.dates.firstIndex(of: date) ?? 0) + 1
                            dateComponents.hour = 8
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            center.add(request) { error in
                                if error != nil {
                                    print(error!.localizedDescription)
                                }
                            }
                        }
                    }) {
                        HStack {
                            if self.allsongs.datesToPractice.contains(self.dates[date]) {
                                Text(self.dates[date])
                                Spacer()
                                Image(systemName: "checkmark")
                            } else {
                                Text(self.dates[date])
                            }
                        }
                    }
                }
            }.navigationBarTitle("Practice Dates")
        }
    }
    func writeToFile() {
        var file = ""
        for date in 0..<allsongs.datesToPractice.count-1 {
            file += allsongs.datesToPractice[date] + "\n"
        }
        file += allsongs.datesToPractice[allsongs.datesToPractice.count-1]
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let fileURL = documentsDirectory.appendingPathComponent("Dates.txt")
            let exists = FileManager().fileExists(atPath: fileURL.path)
            if exists == true {
                do {
                    try file.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch let e {
                    print(e.localizedDescription)
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var keyboardRespond = KeyboardResponder()
    @State private var isShareSheetShowing = false
    @State var customizedPractice = false
    @EnvironmentObject var allsongs: AllSongs
    @State var allLabels = loadLabels()
    @State var elapsed = 0
    @State var tempsongs: [[Song]] = []
    @State var playedsongs = loadPlayedSongs()
    @State var newsection = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var ragams = loadRagamsComposers()[0]
    var composers = loadRagamsComposers()[1]
    @State var selectedRagam = 0
    @State var selectedComposer = 0
    @State var showRagams: Bool = false
    @State var showComposers: Bool = false
    @State var showAddSheet: Bool = false
    @State var showDatePicker: Bool = false
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Picker(selection: $selectedRagam, label: Text("Filter Ragam")) {
                        ForEach(0 ..< ragams.count, id: \.self) {
                            Text(self.ragams[$0])
                        }
                    }
                    Picker(selection: $selectedComposer, label: Text("Filter Composer")) {
                        ForEach(0 ..< composers.count, id: \.self) {
                            Text(self.composers[$0])
                        }
                    }
                    Button(action: {
                        self.showDatePicker.toggle()
                    }) {
                        Text("Days to Practice: " + allsongs.datesToPractice.joined(separator: ", ") + " (Press to modify)")
                    }.sheet(isPresented: self.$showDatePicker) {
                        PracticeDates().environmentObject(self.allsongs)
                    }
                    ForEach(allLabels, id: \.self) { label in
                        Section(header: Text(label)) {
                            ForEach(self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!].filter { (($0.ragam == self.ragams[self.selectedRagam] && self.selectedComposer == 0) || ($0.composer == self.composers[self.selectedComposer] && self.selectedRagam == 0)) || (self.selectedComposer == 0 && self.selectedRagam == 0) || ($0.ragam == self.ragams[self.selectedRagam] && $0.composer == self.composers[self.selectedComposer])}, id: \.self) { song in
                                Button (action: {
                                    if (song.color != ColorManager.subtleBlue) {
                                        let df = DateFormatter()
                                        df.dateFormat = "yyyy-MM-dd"
                                        thechange(fullsong: song, date: df.string(from: Date()))
                                        for i in 0...self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!].count-1 {
                                            if self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!][i].songname == song.songname {
                                                self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!][i].color = ColorManager.subtleBlue
                                                self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!][i].message = "Days since last played: 0"
                                            }
                                        }
                                        self.playedsongs[self.allLabels.firstIndex(of: label)!].append(exactSong(songs2: song.songname))
                                    } else {
                                        thechange(fullsong: song, date: song.date)
                                        for i in 0...self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!].count-1 {
                                            if self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!][i].songname == song.songname {
                                                self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!][i].color = color(songs3: song.songname)
                                                self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!][i].message = "Days since last played: \(daysSince(songs1: song.songname))"
                                            }
                                        }
                                        if self.playedsongs[self.allLabels.firstIndex(of: label)!].firstIndex(of: exactSong(songs2: song.songname)) != nil {
                                            self.playedsongs[self.allLabels.firstIndex(of: label)!].remove(at: self.playedsongs[self.allLabels.firstIndex(of: label)!].firstIndex(of: exactSong(songs2: song.songname))!)
                                            }
                                    }
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(song.display)
                                                .padding()
                                                .foregroundColor(.black)
                                                .contextMenu {
                                                    Text("Ragam: " + song.ragam)
                                                    Text("Composer: " + song.composer)
                                                }
                                        Text(song.message).font(.subheadline).foregroundColor(.black)
                                    }
                                    Spacer()
                                }
                                .listRowBackground(song.color)
                            }
                            .onDelete { (IndexSet) in
                                self.allsongs.allsongs[self.allLabels.firstIndex(of: label)!].remove(atOffsets: IndexSet)
                                deleteSong(songs: self.allsongs.allsongs, labels: self.allLabels)
                            }
                            Button(action: {
                                self.showAddSheet.toggle()
                            }) {
                                Text("Add a new song")
                            }.sheet(isPresented: self.$showAddSheet) {
                                AddNewSong(labels: self.allLabels, label: label).environmentObject(self.allsongs)
                            }
                        }
                    }
                    TextField("Enter a new section", text: $newsection, onCommit: {
                        if self.newsection.count > 0 {
                            self.allLabels.append(self.newsection)
                            addSection(title: self.newsection)
                            self.allsongs.allsongs.append([])
                            self.newsection = ""
                        }
                    })
                    .disableAutocorrection(true)
                }
                .navigationBarTitle("Practice Helper")
                .navigationBarItems(leading: Button(action: {
                    self.customizedPractice.toggle()
                    var each = true
                    for i in self.allsongs.allsongs {
                        if i.count < 2 {
                            each = false
                        }
                    }
                    if (self.customizedPractice == true && each == true) {
                        self.tempsongs = self.allsongs.allsongs
                        for i in 0..<self.allsongs.allsongs.count {
                            self.allsongs.allsongs[i] = [self.allsongs.allsongs[i][0], self.allsongs.allsongs[i][1]]
                        }
                    } else {
                        for i in 0..<self.tempsongs.count {
                            for item in 2..<self.tempsongs[i].count {
                                self.allsongs.allsongs[i].append(self.tempsongs[i][item])
                            }
                        }
                        for i in 0..<self.allsongs.allsongs.count {
                            self.allsongs.allsongs[i].sort(by: {$0.dayssince > $1.dayssince})
                        }
                    }
                }) {
                    Image(systemName: "music.note.list")
                        .foregroundColor(ColorManager.subtleBlue)
                }, trailing: Text("\(elapsed / 3600):\(String(format: "%02d", elapsed/60)):\(String(format: "%02d", elapsed % 60))"))
                    .onReceive(timer) { _ in
                        self.elapsed += 1
                    }
                .foregroundColor(ColorManager.subtleBlue)
                .listStyle(GroupedListStyle())
            }
            .offset(y: -keyboardRespond.currentHeight*0.9)
            Button(action: shareButton) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title)
                    .foregroundColor(ColorManager.subtleBlue)
            }
        }
    }
    func shareButton() {
        isShareSheetShowing.toggle()
        var items = "Time I played today: \(elapsed / 3600):\(String(format: "%02d", elapsed/60)):\(String(format: "%02d", elapsed % 60))\n"
        if (self.playedsongs.count > 0) {
            for i in 0..<allLabels.count {
                if self.playedsongs[i].count > 0 {
                    items += allLabels[i] + " I played: \n"
                    for j in self.playedsongs[i] {
                        items += j + "\n"
                    }
                }
            }
        }
        let ac = UIActivityViewController(activityItems: [items], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(ac, animated: true, completion: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
