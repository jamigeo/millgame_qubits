import qsharp
from Quantum.mill import QuantumMill
from qsharp import Result

from Microsoft.Quantum.Simulation import Resources
from Microsoft.Quantum.Simulation.Core import CoreDriver

def run_quantum_mill():
    # Erstelle einen Q# Core-Driver
    driver = CoreDriver()
    
    # Füge die Datei mit dem Q#-Programm hinzu
    driver.load_package("QuantumMill", Resources.get_provider().get_resource("C:/Users/jan-m/Desktop/Mühle/mill.qs"))
    
    # Rufe den Einstiegspunkt des Q#-Programms auf
    driver.run("QuantumMill.EntryPoint")

if __name__ == "__main__":
    run_quantum_mill()
