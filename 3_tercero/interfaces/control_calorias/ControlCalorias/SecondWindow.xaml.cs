using ControlCalorias.Model;
using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace ControlCalorias
{
    public partial class SecondWindow
    {
        private readonly ObservableCollection<Dia> ListaDias;
        private string CampoAnteriorDias;
        private string CampoAnteriorComidas;
        private ListSortDirection DireccionAnteriorDias;
        private ListSortDirection DireccionAnteriorComidas;
        private Dia DiaSeleccion;

        public SecondWindow(ObservableCollection<Dia> listaDias)
        {
            InitializeComponent();

            ListaDias = listaDias;
            TablaDias.ItemsSource = ListaDias;
        }

        public event EventHandler<DiaEventArgs> DiaCambiado;
        public event EventHandler ListaDiasOrdenada;
        public event EventHandler ListaComidasOrdenada;
        public event EventHandler VentanaCerrada;

        internal void OnDiaCambiado(Dia dia)
        {
            DiaCambiado(this, new DiaEventArgs(dia));
        }

        internal void OnListaDiasOrdenada()
        {
            ListaDiasOrdenada(this, new EventArgs());
        }

        internal void OnListaComidasOrdenada()
        {
            ListaComidasOrdenada(this, new EventArgs());
        }

        internal void OnVentanaCerrada()
        {
            VentanaCerrada(this, new EventArgs());
        }

        internal void Main_DiaDeseleccionado(object sender, EventArgs e)
        {
            TablaDias.UnselectAll();
        }

        internal void Main_DiaSeleccionado(object sender, DiaEventArgs e)
        {
            TablaDias.SelectedItem = e.MiDia;
        }

        private void TablaDias_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (TablaDias.SelectedItem != null)
            {
                TablaComidas.ItemsSource = ((Dia)TablaDias.SelectedItem).ListaComidas;
                DiaSeleccion = (Dia)e.AddedItems[0];
            }
            else
            {
                TablaComidas.ItemsSource = null;
                DiaSeleccion = null;
            }

            OnDiaCambiado(DiaSeleccion);
        }

        private void TablaComidas_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            ButtonAddCalorias.IsEnabled = TablaComidas.SelectedItem != null;
        }

        private void ButtonAddDia_Click(object sender, RoutedEventArgs e)
        {
            AddDia ventanaDia = new AddDia(ListaDias)
            {
                Owner = this,
            };
            ventanaDia.DiaAdded += VentanaDia_DiaAdded;
            _ = ventanaDia.ShowDialog();
        }

        private void VentanaDia_DiaAdded(object sender, DiaEventArgs e)
        {
            TablaDias.ScrollIntoView(e.MiDia);
            TablaDias.SelectedItem = e.MiDia;
        }

        private void ButtonAddCalorias_Click(object sender, RoutedEventArgs e)
        {
            AddCalorias ventanaDia = new AddCalorias((Comida)TablaComidas.SelectedItem)
            {
                Owner = this,
            };
            _ = ventanaDia.ShowDialog();
        }

        private void Window_Closing(object sender, CancelEventArgs e)
        {
            e.Cancel = true;
            Hide();
            OnVentanaCerrada();
        }

        private void Window_MouseDown(object sender, MouseButtonEventArgs e)
        {
            HitTestResult res = VisualTreeHelper.HitTest(this, e.GetPosition(this));
            if (res.VisualHit.GetType() != typeof(ListView))
            {
                TablaDias.UnselectAll();
            }
        }

        private void Borrar_Click(object sender, RoutedEventArgs e)
        {
            _ = ListaDias.Remove(DiaSeleccion);
        }

        private void TablaComidas_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            if (TablaComidas.SelectedItem == null)
            {
                return;
            }

            AddCalorias ventanaDia = new AddCalorias((Comida)TablaComidas.SelectedItem)
            {
                Owner = this,
            };
            _ = ventanaDia.ShowDialog();
        }

        private void TablaComidas_KeyDown(object sender, KeyEventArgs e)
        {
            if (TablaComidas.SelectedItem == null)
            {
                return;
            }

            if (e.Key == Key.Enter)
            {
                AddCalorias ventanaDia = new AddCalorias((Comida)TablaComidas.SelectedItem)
                {
                    Owner = this,
                };
                _ = ventanaDia.ShowDialog();
            }
        }

        private void TablaComidasColumnHeader_Click(object sender, RoutedEventArgs e)
        {
            string ordenarPor = ((GridViewColumnHeader)sender).Tag.ToString();
            ListSortDirection direccion;

            TablaComidas.Items.SortDescriptions.Clear();

            if (CampoAnteriorComidas == ordenarPor && DireccionAnteriorComidas == ListSortDirection.Ascending)
            {
                direccion = ListSortDirection.Descending;
                if (DiaSeleccion != null)
                {
                    if (ordenarPor == "Tipo")
                    {
                        DiaSeleccion.ListaComidas.Sort((x, y) => y.Tipo.CompareTo(x.Tipo));
                    }
                    else if (ordenarPor == "Calorias")
                    {
                        DiaSeleccion.ListaComidas.Sort((x, y) => y.Calorias.CompareTo(x.Calorias));
                    }
                }
            }
            else
            {
                direccion = ListSortDirection.Ascending;
                if (DiaSeleccion != null)
                {
                    if (ordenarPor == "Tipo")
                    {
                        DiaSeleccion.ListaComidas.Sort((x, y) => x.Tipo.CompareTo(y.Tipo));
                    }
                    else if (ordenarPor == "Calorias")
                    {
                        DiaSeleccion.ListaComidas.Sort((x, y) => x.Calorias.CompareTo(y.Calorias));
                    }
                }
            }

            CampoAnteriorComidas = ordenarPor;
            DireccionAnteriorComidas = direccion;
            TablaComidas.Items.SortDescriptions.Add(new SortDescription(ordenarPor, direccion));
            OnListaComidasOrdenada();
        }

        private void TablaDiasColumnHeader_Click(object sender, RoutedEventArgs e)
        {
            string ordenarPor = ((GridViewColumnHeader)sender).Tag.ToString();
            ListSortDirection direccion;

            if (CampoAnteriorDias == ordenarPor && DireccionAnteriorDias == ListSortDirection.Ascending)
            {
                direccion = ListSortDirection.Descending;
                ShellSort(ListaDias, false, ordenarPor);
            }
            else
            {
                direccion = ListSortDirection.Ascending;
                ShellSort(ListaDias, true, ordenarPor);
            }

            CampoAnteriorDias = ordenarPor;
            DireccionAnteriorDias = direccion;
            OnListaDiasOrdenada();
        }

        private void ShellSort(ObservableCollection<Dia> o, bool asc, string ordenarPor)
        {
            bool fecha = ordenarPor == "Fecha";
            int length = o.Count;

            for (int h = length / 2; h > 0; h /= 2)
            {
                for (int i = h; i < length; i += 1)
                {
                    Dia temp = o[i];

                    int j;
                    if (fecha)
                    {
                        for (j = i; j >= h && ((o[j - h].Fecha.CompareTo(temp.Fecha) > 0 && asc) ||
                            (temp.Fecha.CompareTo(o[j - h].Fecha) > 0 && !asc)); j -= h)
                        {
                            Dia item = o[j - h];
                            _ = o.Remove(item);
                            o.Insert(j, item);
                        }
                    }
                    else
                    {
                        for (j = i; j >= h && ((o[j - h].TotalCalorias.CompareTo(temp.TotalCalorias) > 0 && asc) ||
                            (temp.TotalCalorias.CompareTo(o[j - h].TotalCalorias) > 0 && !asc)); j -= h)
                        {
                            Dia item = o[j - h];
                            _ = o.Remove(item);
                            o.Insert(j, item);
                        }
                    }

                    _ = o.Remove(temp);
                    o.Insert(j, temp);
                }
            }
        }
    }
}
