using System;
using System.IO;
using CsvHelper;
using CsvHelper.Configuration;

namespace NineMensMorris
{
    class Program
    {
        static void Main(string[] args)
        {
            string csvFilePath = "data.csv";

            // Schreiben der Daten in die CSV-Datei
            using (var writer = new StreamWriter(csvFilePath))
            using (var csv = new CsvWriter(writer, new CsvConfiguration(System.Globalization.CultureInfo.InvariantCulture)
            {
                HasHeaderRecord = true,
            }))
            {
                csv.WriteField("Operation");
                csv.WriteField("ExecutionTime");
                csv.NextRecord();

                using (var sim = new Simulator())
                {
                    WriteOperationData(sim, csv, "MainOperation");
                    WriteOperationData(sim, csv, "ExampleNineMensMorrisGame");
                }
            }

            Console.WriteLine($"Data exported to {csvFilePath}");
        }

        static void WriteOperationData(SimulatorBase simulator, CsvWriter csv, string operationName)
        {
            var startTime = DateTime.Now;

            // Simuliere die Operation (hier nur als Beispiel)
            if (operationName == "MainOperation")
            {
                MainOperation.Run(simulator);
            }
            else if (operationName == "ExampleNineMensMorrisGame")
            {
                ExampleNineMensMorrisGame.Run(simulator);
            }

            var endTime = DateTime.Now;
            var executionTime = (endTime - startTime).TotalMilliseconds;

            csv.WriteField(operationName);
            csv.WriteField(executionTime);
            csv.NextRecord();
        }

        // Definition der Klassen SimulatorBase, Simulator, MainOperation, ExampleNineMensMorrisGame wie zuvor
        // ...

        public abstract class SimulatorBase : IDisposable
        {
            public abstract void Dispose();
        }

        internal class Simulator : SimulatorBase
        {
            public override void Dispose()
            {
                Console.WriteLine("Simulator disposed.");
            }
        }

        public class MainOperation
        {
            internal static void Run(SimulatorBase simulator)
            {
                // Hier können Sie die Logik der MainOperation implementieren
                Console.WriteLine("MainOperation executed.");
                System.Threading.Thread.Sleep(1000); // Beispiel für eine Verzögerung
            }
        }

        internal class ExampleNineMensMorrisGame
        {
            internal static void Run(SimulatorBase simulator)
            {
                // Hier können Sie die Logik des Beispielspiels implementieren
                Console.WriteLine("Example Nine Men's Morris game running...");
                System.Threading.Thread.Sleep(500); // Beispiel für eine Verzögerung
            }
        }
    }
}