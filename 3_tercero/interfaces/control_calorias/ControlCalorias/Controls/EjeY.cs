using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;

namespace ControlCalorias.Controls
{
    public class EjeY : StackPanel
    {
        private readonly TextBlock Relleno;
        private readonly double factorNumSteps = 33;
        private readonly List<MarcaEje> ListaMarcas;
        private double MaxValue;
        private double PixelPerUnit;
        private double StepValue;
        private double StepHeight;
        private int NumeroSteps;

        public EjeY(double maxHeight, double maxValue)
        {
            VerticalAlignment = VerticalAlignment.Bottom;
            Margin = new Thickness(0, 0, 0, 20);

            Relleno = new TextBlock
            {
                Text = "\n\n",
                FontSize = 10,
            };

            NumeroSteps = (int)Math.Round(maxHeight / factorNumSteps);
            PixelPerUnit = maxValue / maxHeight;
            StepValue = Math.Ceiling(maxValue / NumeroSteps / 100) * 100;
            MaxValue = StepValue * NumeroSteps;
            StepHeight = StepValue / PixelPerUnit;
            MaxValue = StepValue * NumeroSteps;

            Visibility = double.IsNaN(MaxValue) || (MaxValue == 0) ? Visibility.Hidden : Visibility.Visible;

            StepHeight = StepValue / PixelPerUnit;

            ListaMarcas = new List<MarcaEje>
            {
                new MarcaEje(MaxValue, double.NaN),
            };
            for (int i = 1; i < NumeroSteps + 1; i++)
            {
                ListaMarcas.Add(new MarcaEje(MaxValue - (StepValue * i), StepHeight));
            }

            foreach (MarcaEje marcaEje in ListaMarcas)
            {
                _ = Children.Add(marcaEje);
            }

            _ = Children.Add(Relleno);
        }

        public void ActualizarEjeY(double maxHeight, double maxValue)
        {
            bool cambioNumSteps;
            if (NumeroSteps != (int)Math.Round(maxHeight / factorNumSteps))
            {
                cambioNumSteps = true;
                NumeroSteps = (int)Math.Round(maxHeight / factorNumSteps);
            }
            else
            {
                cambioNumSteps = false;
            }

            PixelPerUnit = maxValue / maxHeight;
            StepValue = Math.Ceiling(maxValue / NumeroSteps / 100) * 100;
            MaxValue = StepValue * NumeroSteps;

            if (double.IsNaN(MaxValue))
            {
                MaxValue = 0;
                StepValue = 0;
            }

            Visibility = double.IsNaN(MaxValue) || (MaxValue == 0) ? Visibility.Hidden : Visibility.Visible;

            StepHeight = StepValue / PixelPerUnit;

            if (cambioNumSteps)
            {
                ListaMarcas.Clear();
                Children.Clear();

                ListaMarcas.Add(new MarcaEje(MaxValue, double.NaN));
                for (int i = 1; i < NumeroSteps + 1; i++)
                {
                    ListaMarcas.Add(new MarcaEje(MaxValue - (StepValue * i), StepHeight));
                }

                foreach (MarcaEje marcaEje in ListaMarcas)
                {
                    _ = Children.Add(marcaEje);
                }

                _ = Children.Add(Relleno);
            }
            else
            {
                ListaMarcas[0].ActualizarMarca(MaxValue, double.NaN);
                for (int i = 1; i < NumeroSteps + 1; i++)
                {
                    ListaMarcas[i].ActualizarMarca(MaxValue - (StepValue * i), StepHeight);
                }
            }
        }
    }
}
