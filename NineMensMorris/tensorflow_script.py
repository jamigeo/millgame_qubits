import tensorflow as tf
import numpy as np
import subprocess
import os

# Pfad zur Ausgabedatei
file_path = r"C:\Users\jan-m\Desktop\Mühle\NineMensMorris\output.log"

# Funktion zum Starten des Q#-Programms und Erfassen der Ausgabe
def run_qsharp_program():
    # Stellen Sie sicher, dass Sie den Pfad zu Ihrem Q#-Projektverzeichnis anpassen
    project_dir = r"C:\Users\jan-m\Desktop\Mühle\NineMensMorris"

    try:
        result = subprocess.run(['dotnet', 'run'], cwd=project_dir, capture_output=True, text=True)
        if result.returncode == 0:
            print("Q# program executed successfully")
        else:
            print(f"Q# program failed with return code {result.returncode}")
            print(result.stderr)
    except Exception as e:
        print(f"An error occurred: {e}")

# Funktion zum Laden und Vorverarbeiten der Daten
def load_data(file_path):
    if not os.path.exists(file_path):
        return np.array([])

    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Beispiel für die Vorverarbeitung: Extrahieren von Nachrichten und Konvertieren in numerische Werte
    data = []
    for line in lines:
        if "BestMoveIndex" in line:
            parts = line.split(":")
            if len(parts) == 2:
                data.append(int(parts[1].strip()))

    return np.array(data)

# Funktion zum Extrahieren der besten Züge aus den gespeicherten Daten
def extract_best_moves(data, num_moves=10):
    if data.size == 0:
        return []

    sorted_indices = np.argsort(data)[-num_moves:][::-1]  # Indices der besten num_moves Züge
    best_moves = data[sorted_indices]
    return best_moves

# Einfaches TensorFlow-Modell erstellen und kompilieren
model = tf.keras.Sequential([
    tf.keras.layers.Dense(10, activation='relu', input_shape=(1,)),
    tf.keras.layers.Dense(1)
])
model.compile(optimizer='adam', loss='mean_squared_error')

# Schleife für mehrere Iterationen
num_iterations = 5  # Anzahl der Iterationen
for iteration in range(num_iterations):
    # Q#-Programm ausführen und Daten laden
    run_qsharp_program()
    data = load_data(file_path)

    # Extrahiere die besten Züge aus den gespeicherten Daten
    best_moves = extract_best_moves(data)

    # Modell mit den aktuellen besten Zügen trainieren
    if len(best_moves) > 0:
        x_train = np.arange(len(best_moves)).reshape(-1, 1)
        y_train = best_moves

        model.fit(x_train, y_train, epochs=10, verbose=0)  # Trainiere das Modell leise

    # Vorhersage der besten Züge für die nächste Iteration
    if iteration < num_iterations - 1:
        predicted_best_moves = model.predict(np.arange(10).reshape(-1, 1)).flatten()
        print(f"Iteration {iteration + 1}: Predicted best moves: {predicted_best_moves}")

# Letzte Vorhersage nach der letzten Iteration
final_predicted_moves = model.predict(np.arange(10).reshape(-1, 1)).flatten()
print(f"Final predicted best moves: {final_predicted_moves}")
