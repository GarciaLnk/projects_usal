using ControlCalorias.Controls;
using ControlCalorias.Model;
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;

namespace ControlCalorias
{
    public class DiaEventArgs : EventArgs
    {
        public Dia MiDia { get; set; }

        public DiaEventArgs(Dia dia)
        {
            MiDia = dia;
        }
    }

    public partial class MainWindow
    {
        private readonly ObservableCollection<Dia> ListaDias = new ObservableCollection<Dia>();
        private readonly EjeY EjeYCalorias = new EjeY(0, 0);
        private SecondWindow VentanaTablas;
        private Dia DiaSeleccion;

        public MainWindow()
        {
            InitializeComponent();

            Application.Current.ShutdownMode = ShutdownMode.OnMainWindowClose;
            VentanaTablas = new SecondWindow(ListaDias);
            VentanaTablas.DiaCambiado += Tablas_DiaCambiado;
            VentanaTablas.ListaComidasOrdenada += Tablas_ListaComidasOrdenada;
            VentanaTablas.ListaDiasOrdenada += Tablas_ListaDiasOrdenada;
            VentanaTablas.VentanaCerrada += VentanaTablas_VentanaCerrada;
            DiaDeseleccionado += VentanaTablas.Main_DiaDeseleccionado;
            DiaSeleccionado += VentanaTablas.Main_DiaSeleccionado;
            VentanaTablas.Show();

            _ = GridBarras.Children.Add(EjeYCalorias);

            ListaDias.CollectionChanged += ListaDias_CollectionChanged;
        }

        public event EventHandler DiaDeseleccionado;
        public event EventHandler<DiaEventArgs> DiaSeleccionado;

        internal void OnDiaDeseleccionado()
        {
            DiaDeseleccionado(this, new EventArgs());
        }

        internal void OnDiaSeleccionado(Dia dia)
        {
            DiaSeleccionado(this, new DiaEventArgs(dia));
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            VentanaTablas.Top = Top;
            VentanaTablas.Left = Left - VentanaTablas.ActualWidth;
        }

        private void CargarDatosAleatorios()
        {
            Random rand = new Random();

            for (int i = 0; i < 15; i++)
            {
                DateTime start = new DateTime(2016, 1, 1);
                int range = (DateTime.Today - start).Days;
                Dia nuevoDia = new Dia(start.AddDays(rand.Next(range)));

                foreach (Comida comida in nuevoDia.ListaComidas)
                {
                    comida.Calorias = rand.Next(5, 750);
                }

                ListaDias.Add(nuevoDia);
            }
        }

        private void VentanaTablas_VentanaCerrada(object sender, EventArgs e)
        {
            AbrirTablas.IsEnabled = true;
        }

        private void Tablas_DiaCambiado(object sender, DiaEventArgs e)
        {
            if (e.MiDia != null)
            {
                DiaSeleccion = e.MiDia;
                if (DiaSeleccion != null)
                {
                    ButtonVerTodo.Visibility = Visibility.Visible;
                    MostrarBarrasComida(DiaSeleccion);
                    GridBarras.Margin = new Thickness(20, 10, 20, 20);
                }
            }
            else
            {
                ButtonVerTodo.Visibility = Visibility.Collapsed;
                MostrarBarrasDia();
                GridBarras.Margin = new Thickness(20);
            }

            ActualizarBarras();
        }

        private void MostrarBarrasComida(Dia dia)
        {
            if (dia == null)
            {
                return;
            }

            foreach (StackPanel sp in StackBarras.Children)
            {
                sp.Children.Clear();
            }

            StackBarras.Children.Clear();

            foreach (Comida comida in dia.ListaComidas)
            {
                StackPanel sp = new StackPanel
                {
                    VerticalAlignment = VerticalAlignment.Bottom,
                    Margin = new Thickness(0, 0, 0, 20),
                };
                _ = sp.Children.Add(comida.Barra);
                _ = sp.Children.Add(comida.EtiquetaComida);
                _ = StackBarras.Children.Add(sp);
            }
        }

        private void MostrarBarrasDia()
        {
            foreach (StackPanel sp in StackBarras.Children)
            {
                sp.Children.Clear();
            }

            StackBarras.Children.Clear();

            DiaSeleccion = null;

            foreach (Dia dia in ListaDias)
            {
                StackPanel sp = new StackPanel
                {
                    VerticalAlignment = VerticalAlignment.Bottom,
                    Margin = new Thickness(0, 0, 0, 20),
                };
                for (int i = dia.ListaComidas.Count - 1; i >= 0; i--)
                {
                    _ = sp.Children.Add(dia.ListaComidas[i].Barra);
                }

                _ = sp.Children.Add(dia.EtiquetaFecha);
                _ = StackBarras.Children.Add(sp);
            }
        }

        private void ActualizarBarras()
        {
            double caloriasMax;
            double pxPerCal = 0;
            double ancho;

            if (!ListaDias.Any())
            {
                EjeYCalorias.ActualizarEjeY(0, 0);
                return;
            }

            if (DiaSeleccion == null)
            {
                caloriasMax = ListaDias.Max(x => x.TotalCalorias);
                ancho = GridBarras.ActualWidth / ListaDias.Count();
            }
            else
            {
                caloriasMax = DiaSeleccion.ListaComidas.Max(x => x.Calorias);
                ancho = GridBarras.ActualWidth / Enum.GetValues(typeof(Comidas)).Length;
            }

            if (caloriasMax != 0)
            {
                pxPerCal = (StackBarras.ActualHeight - 100) / caloriasMax;
            }

            foreach (Dia dia in ListaDias)
            {
                foreach (Comida comida in dia.ListaComidas)
                {
                    comida.ActualizarBarra(pxPerCal, ancho);
                }
            }

            EjeYCalorias.ActualizarEjeY(GridBarras.ActualHeight - 100, caloriasMax);
        }

        private void Dia_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            ActualizarBarras();
        }

        private void ListaDias_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.NewItems != null)
            {
                foreach (Dia dia in e.NewItems)
                {
                    string tmp;
                    int resto = ListaDias.Count % 3;

                    switch (resto)
                    {
                        case 1:
                            tmp = $"\n\n{dia.FechaString}";
                            break;
                        case 2:
                            tmp = $"\n{dia.FechaString}\n";
                            break;
                        default:
                            tmp = $"{dia.FechaString}\n\n";
                            break;
                    }

                    dia.EtiquetaFecha.Text = tmp;

                    if (DiaSeleccion == null)
                    {
                        StackPanel sp = new StackPanel
                        {
                            VerticalAlignment = VerticalAlignment.Bottom,
                            Margin = new Thickness(0, 0, 0, 20),
                        };

                        for (int i = dia.ListaComidas.Count - 1; i >= 0; i--)
                        {
                            _ = sp.Children.Add(dia.ListaComidas[i].Barra);
                            dia.ListaComidas[i].Barra.MouseLeftButtonDown += Barra_MouseLeftButtonDown;
                        }

                        Binding bindingCal = new Binding("TotalCalorias")
                        {
                            Source = dia,
                        };
                        ToolTip tt = new ToolTip();
                        _ = tt.SetBinding(ContentProperty, bindingCal);
                        sp.ToolTip = tt;

                        _ = sp.Children.Add(dia.EtiquetaFecha);
                        _ = StackBarras.Children.Add(sp);
                        ScrollBarras.ScrollToRightEnd();
                    }

                    dia.PropertyChanged += Dia_PropertyChanged;
                }
            }

            if (e.OldItems != null)
            {
                if (DiaSeleccion == null)
                {
                    ActualizarEtiquetasFecha();
                    MostrarBarrasDia();
                }
                else
                {
                    MostrarBarrasComida(DiaSeleccion);
                }
            }

            ActualizarBarras();
        }

        private void ActualizarEtiquetasFecha()
        {
            int i = 1;
            ObservableCollection<Dia> listaDias1 = ListaDias;
            foreach (Dia dia in listaDias1)
            {
                string tmp;
                int resto = i++ % 3;

                switch (resto)
                {
                    case 1:
                        tmp = $"\n\n{dia.FechaString}";
                        break;
                    case 2:
                        tmp = $"\n{dia.FechaString}\n";
                        break;
                    default:
                        tmp = $"{dia.FechaString}\n\n";
                        break;
                }

                dia.EtiquetaFecha.Text = tmp;
            }
        }

        private void AbrirTablas_Click(object sender, RoutedEventArgs e)
        {
            if (VentanaTablas == null)
            {
                VentanaTablas = new SecondWindow(ListaDias);
            }

            VentanaTablas.Show();
            AbrirTablas.IsEnabled = false;
        }

        private void ButtonVerTodo_Click(object sender, RoutedEventArgs e)
        {
            ButtonVerTodo.Visibility = Visibility.Collapsed;
            OnDiaDeseleccionado();
        }


        private void GridBarras_MouseRightButtonDown(object sender, MouseButtonEventArgs e)
        {
            ButtonVerTodo.Visibility = Visibility.Collapsed;
            OnDiaDeseleccionado();
        }

        private void Barra_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            bool encontrado = false;
            foreach (Dia dia in ListaDias)
            {
                foreach (Comida comida in dia.ListaComidas)
                {
                    if (sender.Equals(comida.Barra))
                    {
                        encontrado = true;
                        break;
                    }
                }

                if (encontrado)
                {
                    OnDiaSeleccionado(dia);
                    break;
                }
            }
        }

        private async void Window_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            await Task.Delay(10);
            ActualizarBarras();
        }

        private async void ButtonVerTodo_IsVisibleChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
            await Task.Delay(10);
            ActualizarBarras();
        }

        private void Tablas_ListaComidasOrdenada(object sender, EventArgs e)
        {
            MostrarBarrasComida(DiaSeleccion);
        }

        private void Tablas_ListaDiasOrdenada(object sender, EventArgs e)
        {
            ActualizarEtiquetasFecha();
            MostrarBarrasDia();
        }

        private void CargarDatos_Click(object sender, RoutedEventArgs e)
        {
            CargarDatosAleatorios();
        }
    }
}
