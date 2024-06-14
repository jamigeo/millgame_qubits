import qsharp

# Laden des Quantum-Skripts
qsharp.reload()

# Jetzt können Sie die Q#-Operationen importieren
from NineMensMorris import Main, ExampleNineMensMorrisGame

# Ausführen des Hauptprogramms
Main.simulate()

# Beispiel für das Nine Men's Morris Spiel ausführen
ExampleNineMensMorrisGame.simulate()
