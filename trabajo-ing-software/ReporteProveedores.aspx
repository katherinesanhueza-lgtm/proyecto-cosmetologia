<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReporteProveedores.aspx.cs" Inherits="trabajo_ing_software.ReporteProveedores" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Reporte: Evaluación de Proveedores - Dermocosmética</title>
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--color-primario);
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        /* Tarjetas de Métricas (KPIs) */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .kpi-card {
            background-color: var(--color-blanco);
            border-radius: 18px;
            padding: 22px;
            border: 1px solid var(--color-primario);
            box-shadow: 0 4px 15px rgba(139, 111, 86, 0.05);
            text-align: center;
        }
        .kpi-valor {
            font-family: 'Playfair Display', serif;
            font-size: 32px;
            font-weight: 700;
            color: var(--color-acento);
            margin: 8px 0;
        }
        .kpi-titulo {
            font-size: 13px;
            color: var(--color-secundario);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }
        .badge-excelente {
            background-color: #E8F8F0;
            color: #27AE60;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-aceptable {
            background-color: #FEF9E7;
            color: #D4AC0D;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-critico {
            background-color: #FDEDEC;
            color: #C0392B;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        /* Estilos al imprimir */
        @media print {
            .no-print {
                display: none !important;
            }
            .container {
                max-width: 100%;
                margin: 0;
                padding: 0;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <!-- Barra superior -->
            <div class="header-top no-print">
                <div>
                    <h1 style="margin: 0; font-size: 26px;">Reporte: Evaluación de Proveedores</h1>
                    <span style="font-size: 13px; color: var(--color-secundario);">MÓDULO DE COMPRAS • CUMPLIMIENTO Y TIEMPOS DE ENTREGA</span>
                </div>
                <div class="nav-links">
                    <asp:Button ID="btnVolver" runat="server" Text="← Volver a Laboratorios" CssClass="btn-secundario" style="padding: 7px 15px; font-size: 13px;" OnClick="btnVolver_Click" />
                    <button type="button" class="btn-principal" style="padding: 7px 15px; font-size: 13px;" onclick="descargarPDF();">Descargar PDF</button>
                    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesión" CssClass="btn-secundario" style="padding: 7px 15px; font-size: 13px;" OnClick="btnLogout_Click" />
                </div>
            </div>

            <!-- Título al imprimir -->
            <div style="margin-bottom: 20px;">
                <h2 class="titulo-elegante" style="margin-bottom: 5px;">Distribuidora de Dermocosmética Profesional</h2>
                <p style="margin: 0; font-size: 14px; color: var(--color-secundario);">Informe Analítico de Rendimiento y Tiempos de Proveedores</p>
                <small style="color: gray;">Fecha de emisión: <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></small>
            </div>

            <!-- Fila de Tarjetas KPI -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <span class="kpi-titulo">Laboratorios Activos</span>
                    <div class="kpi-valor"><asp:Label ID="lblTotalLaboratorios" runat="server" Text="0"></asp:Label></div>
                    <small style="color: gray;">En catálogo</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Órdenes de Compra</span>
                    <div class="kpi-valor"><asp:Label ID="lblTotalOC" runat="server" Text="0"></asp:Label></div>
                    <small style="color: gray;">Emitidas históricamente</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Crédito Promedio</span>
                    <div class="kpi-valor"><asp:Label ID="lblPromedioDias" runat="server" Text="0"></asp:Label> días</div>
                    <small style="color: gray;">Plazo de pago promedio</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Cumplimiento Global</span>
                    <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblCumplimientoGlobal" runat="server" Text="100%"></asp:Label></div>
                    <small style="color: gray;">Puntualidad de recepción</small>
                </div>
            </div>

            <!-- Tabla Analítica -->
            <div class="card-dermocosmetica">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <h3 style="margin: 0;">Detalle de Rendimiento por Laboratorio</h3>
                </div>

                <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="False" 
                    CssClass="tabla-dermo" GridLines="None" EmptyDataText="No hay datos suficientes para generar el reporte.">
                    <Columns>
                        <asp:BoundField DataField="RazonSocial" HeaderText="Laboratorio" />
                        <asp:BoundField DataField="Marca" HeaderText="Marca" />
                        <asp:BoundField DataField="Pais" HeaderText="País" />
                        <asp:BoundField DataField="DiasPago" HeaderText="Plazo Crédito" />
                        <asp:BoundField DataField="TotalOC" HeaderText="Órdenes Emitidas" />
                        <asp:BoundField DataField="TotalRecepciones" HeaderText="Recepciones" />
                        <asp:TemplateField HeaderText="% Cumplimiento">
                            <ItemTemplate>
                                <strong><%# Eval("PorcentajeCumplimiento") %>%</strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Calificación">
                            <ItemTemplate>
                                <span class='<%# GetClaseCalificacion(Eval("Calificacion").ToString()) %>'>
                                    <%# Eval("Calificacion") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
    <script>
    function descargarPDF() {
        // Seleccionamos todo el contenedor del reporte
        var elemento = document.querySelector('.container');
        
        var opciones = {
            margin:       10,
            filename:     'Reporte_Evaluacion_Proveedores_Dermocosmetica.pdf',
            image:        { type: 'jpeg', quality: 0.98 },
            html2canvas:  { scale: 2 },
            jsPDF:        { unit: 'mm', format: 'a4', orientation: 'landscape' }
        };

        // Genera y descarga el archivo automáticamente
        html2pdf().set(opciones).from(elemento).save();
    }
    </script>
</body>
</html>