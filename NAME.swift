import SwiftUI

@main
struct TaskManagerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
            Text("Tasks To Go")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
                .scaleEffect(1.1)
                .animation(.easeInOut(duration: 5), value: 1.1)

        }
    }
}

// Task Model
struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var isSelected: Bool = false
}

// ViewModel for Managing Tasks
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    
    let tasksKey = "savedTasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.spring()) {
                tasks[index].isCompleted.toggle()
            }
        }
    }
    
    func toggleTaskSelection(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.easeInOut) {
                tasks[index].isSelected.toggle()
            }
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        withAnimation(.easeOut) {
            tasks.remove(atOffsets: offsets)
        }
    }
    
    func deleteSelectedTasks() {
        withAnimation(.easeOut) {
            tasks.removeAll { $0.isSelected }
        }
    }
    
    func deleteAllTasks() {
        withAnimation(.easeOut) {
            tasks.removeAll()
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let savedData = UserDefaults.standard.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
            self.tasks = decodedTasks
        }
    }
}

// Home View
struct HomeView: View {
    @AppStorage("darkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 16
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: TaskListView()) {
                    Text("View Tasks")
                        .font(.system(size: CGFloat(fontSize)))
                        .padding()
                        .background(Color.gray.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding()
                
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .font(.system(size: CGFloat(fontSize)))
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding()
            }
            .navigationTitle("Home")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

// Task List View
struct TaskListView: View {
    @StateObject var taskViewModel = TaskViewModel()
    @AppStorage("darkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 16
    @State private var newTaskTitle = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("New Task", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: CGFloat(fontSize)))
                
                Button(action: {
                    if !newTaskTitle.isEmpty {
                        withAnimation(.spring()) {
                            taskViewModel.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                        }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.pink.opacity(0.8))
                }
            }
            .padding()
            
            List {
                ForEach(taskViewModel.tasks) { task in
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green.opacity(0.8) : .gray.opacity(0.8))
                            .onTapGesture {
                                taskViewModel.toggleTaskCompletion(task: task)
                            }
                        
                        Text(task.title)
                            .strikethrough(task.isCompleted, color: .gray)
                            .foregroundColor(task.isCompleted ? .gray : .primary)
                            .font(.system(size: CGFloat(fontSize)))
                        
                        Spacer()
                        Button(action: {
                            taskViewModel.toggleTaskSelection(task: task)
                        }) {
                            Image(systemName: task.isSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete(perform: taskViewModel.deleteTask)
            }
            .listStyle(PlainListStyle())
            
            HStack {
                Button("Delete Selected") {
                    taskViewModel.deleteSelectedTasks()
                }
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Delete All") {
                    taskViewModel.deleteAllTasks()
                }
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .navigationTitle("Task List")
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// Settings View
struct SettingsView: View {
    @AppStorage("darkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 16
    
    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $isDarkMode)
            
            VStack {
                Text("Font Size: \(Int(fontSize))")
                Slider(value: $fontSize, in: 12...24, step: 1)
            }
        }
        .navigationTitle("Settings")
    }
}

