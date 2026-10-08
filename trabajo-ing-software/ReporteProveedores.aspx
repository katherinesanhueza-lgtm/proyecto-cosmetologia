<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReporteProveedores.aspx.cs" Inherits="trabajo_ing_software.ReporteProveedores" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Reporte: Evaluaci&oacute;n de Proveedores - Dermocosm&eacute;tica</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
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
            border-bottom: 1px solid var(--color-borde-suave);
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        /* Tarjetas de Metricas (KPIs) */
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
            border: 1px solid var(--color-borde-suave);
            box-shadow: 0 4px 15px rgba(122, 94, 71, 0.05);
            text-align: center;
        }
        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
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
                    <h1 style="margin: 0; font-size: 26px;">Reporte: Evaluaci&oacute;n de Proveedores</h1>
                    <span style="font-size: 13px; color: var(--color-texto-suave);">M&Oacute;DULO DE COMPRAS &bull; CUMPLIMIENTO Y TIEMPOS DE ENTREGA</span>
                </div>
                <div class="nav-links">
                    <asp:Button ID="btnVolver" runat="server" Text="Volver a Laboratorios" CssClass="btn-dermo-secondary" style="padding: 7px 15px; font-size: 13px;" OnClick="btnVolver_Click" />
                    <button type="button" class="btn-dermo-primary" style="padding: 7px 18px; font-size: 13px;" onclick="descargarPDF();">Descargar PDF</button>
                    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn-dermo-secondary" style="padding: 7px 15px; font-size: 13px;" OnClick="btnLogout_Click" />
                </div>
            </div>

            <!-- Titulo al imprimir -->
            <div style="margin-bottom: 20px;">
                <h2 style="margin-bottom: 5px;">Distribuidora de Dermocosm&eacute;tica Profesional</h2>
                <p style="margin: 0; font-size: 14px; color: var(--color-texto-suave);">Informe Anal&iacute;tico de Rendimiento y Tiempos de Proveedores</p>
                <small style="color: gray;">Fecha de emisi&oacute;n: <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></small>
            </div>

            <!-- Fila de Tarjetas KPI -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <span class="kpi-titulo">Laboratorios Activos</span>
                    <div class="kpi-valor"><asp:Label ID="lblTotalLaboratorios" runat="server" Text="0"></asp:Label></div>
                    <small style="color: gray;">En cat&aacute;logo</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">&Oacute;rdenes de Compra</span>
                    <div class="kpi-valor"><asp:Label ID="lblTotalOC" runat="server" Text="0"></asp:Label></div>
                    <small style="color: gray;">Emitidas hist&oacute;ricamente</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Cr&eacute;dito Promedio</span>
                    <div class="kpi-valor"><asp:Label ID="lblPromedioDias" runat="server" Text="0"></asp:Label> d&iacute;as</div>
                    <small style="color: gray;">Plazo de pago promedio</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Cumplimiento Global</span>
                    <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblCumplimientoGlobal" runat="server" Text="100%"></asp:Label></div>
                    <small style="color: gray;">Puntualidad de recepci&oacute;n</small>
                </div>
            </div>

            <!-- Tabla de Evaluacion -->
            <div class="table-dermo-container" style="margin-bottom: 30px;">
                <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="False" 
                    CssClass="table-dermo-modern" GridLines="None" EmptyDataText="No hay datos de compras u ordenes registradas para evaluar.">
                    <Columns>
                        <asp:BoundField DataField="RazonSocial" HeaderText="LABORATORIO" />
                        <asp:BoundField DataField="Pais" HeaderText="PA&Iacute;S" HtmlEncode="false" />
                        <asp:BoundField DataField="DiasPago" HeaderText="PLAZO CR&Eacute;DITO" HtmlEncode="false" />
                        <asp:BoundField DataField="TotalOC" HeaderText="ORDENES COMPRA" HtmlEncode="false" />
                        <asp:BoundField DataField="PromedioDiasEntrega" HeaderText="TIEMPO PROMEDIO ENTREGA" HtmlEncode="false" />
                        
                        <asp:TemplateField HeaderText="NIVEL CUMPLIMIENTO">
                            <ItemTemplate>
                                <span class='<%# Eval("ClaseBadge") %>'>
                                    <%# Eval("NivelCumplimiento") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- Resumen explicativo -->
            <div style="background-color: var(--color-blanco); border: 1px solid var(--color-borde-suave); border-radius: 16px; padding: 20px; font-size: 13px; line-height: 1.6; color: var(--color-texto-suave);">
                <strong>Criterio de Evaluaci&oacute;n Comercial y Log&iacute;stica:</strong><br />
                &bull; <strong>Excelente (A):</strong> Entrega en menos o igual al plazo acordado sin retrasos de cadena de fr&iacute;o.<br />
                &bull; <strong>Aceptable (B):</strong> Entrega dentro de una tolerancia de 5 d&iacute;as posteriores a la orden.<br />
                &bull; <strong>Cr&iacute;tico (C):</strong> Retrasos sistem&aacute;ticos que superan la ventana de abastecimiento pactada.
            </div>
        </div>

        <script>
            function descargarPDF() {
                var elemento = document.querySelector('.container');
                var opt = {
                    margin:       [10, 10, 10, 10],
                    filename:     'Reporte_Evaluacion_Proveedores.pdf',
                    image:        { type: 'jpeg', quality: 0.98 },
                    html2canvas:  { scale: 2 },
                    jsPDF:        { unit: 'mm', format: 'a4', orientation: 'landscape' }
                };
                html2pdf().set(opt).from(elemento).save();
            }
        </script>
    </form>
</body>
</html>