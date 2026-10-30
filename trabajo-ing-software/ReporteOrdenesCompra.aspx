<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReporteOrdenesCompra.aspx.cs" Inherits="trabajo_ing_software.ReporteOrdenesCompra" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Reporte: Estado de &Oacute;rdenes de Compra - Cosmetolog&iacute;a Profesional</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .report-container {
            max-width: 1400px;
            margin: 25px auto 50px auto;
            padding: 0 24px;
        }

        .filter-card {
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 20px;
            padding: 20px 24px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
        }

        .filter-grid-5col {
            display: grid;
            grid-template-columns: 180px 180px 1.5fr 160px auto;
            gap: 14px;
            align-items: end;
        }

        .kpi-grid-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 25px;
        }

        .kpi-card {
            background-color: var(--color-blanco);
            border-radius: 18px;
            padding: 20px;
            border: 1px solid var(--color-borde-suave);
            box-shadow: 0 4px 15px rgba(122, 94, 71, 0.04);
            text-align: center;
        }

        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 28px;
            font-weight: 700;
            color: var(--color-acento);
            margin: 6px 0;
        }

        .kpi-titulo {
            font-size: 11px;
            color: var(--color-texto-suave);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Hoja formal de reporte para pantalla e impresión PDF */
        .printable-sheet {
            background-color: var(--color-blanco);
            border-radius: 20px;
            border: 1px solid var(--color-borde-suave);
            padding: 35px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .report-header-banner {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--color-acento);
            padding-bottom: 18px;
            margin-bottom: 25px;
        }

        /* Badges de estado */
        .badge-oc {
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-oc-borrador { background: #F0EFEB; color: #7A756D; }
        .badge-oc-emitida { background: #EBF3FA; color: #2980B9; }
        .badge-oc-parcial { background: #FEF9E7; color: #B7950B; }
        .badge-oc-recibida { background: #E8F8F0; color: #27AE60; }
        .badge-oc-anulada { background: #FDEDEC; color: #C0392B; }

        @media (max-width: 1024px) {
            .filter-grid-5col {
                grid-template-columns: 1fr;
            }
            .kpi-grid-4col {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- HEADER GLOBAL -->
        <header class="top-header">
            <div class="brand-block">
                <span class="brand-logo">NOMBRE</span>
                <span class="brand-sub">COSMETOLOG&Iacute;A PROFESIONAL</span>
            </div>
            <nav>
                <ul class="nav-links-menu">
                    <% 
                        string rolNav = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
                        bool esAdmin = rolNav.Equals("Administrador", StringComparison.OrdinalIgnoreCase);
                        bool esComprador = rolNav.Equals("Comprador", StringComparison.OrdinalIgnoreCase);
                        bool esBodeguero = rolNav.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase);
                        bool esContador = rolNav.Equals("Contador", StringComparison.OrdinalIgnoreCase);
                        bool esVendedor = rolNav.Equals("Vendedor", StringComparison.OrdinalIgnoreCase);

                        // Matriz Oficial RBAC 6.1.2
                        bool puedeVerCompras = esAdmin || esComprador || esContador;
                        bool puedeVerInventario = esAdmin || esBodeguero || esComprador || esContador || esVendedor;
                    %>
                    <li><a href="Default.aspx" class="nav-item-link">Inicio</a></li>

                    <%-- ADMINISTRACIÃ“N (Solo Administrador General) --%>
                    <% if (esAdmin) { %>
                    <li><a href="Usuarios.aspx" class="nav-item-link">Usuarios</a></li>
                    <% } %>

                    <%-- COMPRAS (Admin y Comprador Escritura; Contador Solo Consulta) --%>
                    <% if (esAdmin || esComprador || esContador) { %>
                    <li><a href="Laboratorios.aspx" class="nav-item-link">Laboratorios</a></li>
                    <% } %>
                    <% if (puedeVerCompras) { %>
                    <li><a href="OrdenesCompra.aspx" class="nav-item-link">&Oacute;rdenes de Compra</a></li>
                    <% } %>
                    <% if (esAdmin || esComprador) { %>
                    <li><a href="ReporteProveedores.aspx" class="nav-item-link">Reporte Evaluaci&oacute;n</a></li>
                    <% } %>
                    <% if (puedeVerCompras) { %>
                    <li><a href="ReporteOrdenesCompra.aspx" class="nav-item-link">Reporte &Oacute;rdenes</a></li>
                    <% } %>

                    <%-- INVENTARIO (Bodeguero Escritura; Admin Total; Comprador y Contador Consulta) --%>
                    <% if (esAdmin || esBodeguero || esComprador) { %>
                    <li><a href="Recepciones.aspx" class="nav-item-link">Recepci&oacute;n y Lotes</a></li>
                    <% } %>
                    <% if (puedeVerInventario) { %>
                    <li><a href="ReporteIngresos.aspx" class="nav-item-link">Reporte Ingresos</a></li>
                    <% } %>

                    <%-- ACCESOS (Solo Administrador General) --%>
                    <% if (esAdmin) { %>
                    <li><a href="Accesos.aspx" class="nav-item-link">Accesos</a></li>
                    <% } %>
                </ul>
            </nav>
            <div class="header-actions">
                <asp:Label ID="lblBienvenida" runat="server" Font-Bold="true" Font-Size="13px"></asp:Label>
                <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn-dermo-secondary" style="padding: 7px 16px; font-size: 12px;" OnClick="btnLogout_Click" />
                <div class="user-avatar-btn" title="Usuario">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                </div>
            </div>
        </header>

        <!-- CONTENEDOR PRINCIPAL -->
        <div class="report-container">

            <!-- ENCABEZADO Y ACCIONES DE EXPORTACION -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">REPORTE ANAL&Iacute;TICO N&deg; 3 - COMPRAS</span>
                    <h1 style="font-size: 26px; margin-top: 4px;">Estado de &Oacute;rdenes de Compra</h1>
                    <p class="text-muted" style="margin-top: 4px;">Monitoreo anal&iacute;tico de pedidos pendientes, recibidos y anulados, con liquidaci&oacute;n de IVA Cr&eacute;dito Fiscal (RF-COM-11 / RNF-14).</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="button" onclick="exportarPDF();" class="btn-dermo-primary" style="display: inline-flex; align-items: center; gap: 6px; cursor: pointer;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><line x1="9" y1="15" x2="15" y2="15"></line></svg>
                        Descargar PDF
                    </button>
                    <asp:Button ID="btnExportarExcel" runat="server" Text="Exportar CSV" CssClass="btn-dermo-secondary" OnClick="btnExportarExcel_Click" />
                </div>
            </div>

            <!-- TARJETAS DE KPIS ANALITICOS -->
            <div class="kpi-grid-4col">
                <div class="kpi-card">
                    <div class="kpi-titulo">Total &Oacute;rdenes</div>
                    <div class="kpi-valor"><asp:Label ID="lblKpiTotalOC" runat="server" Text="0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">En el per&iacute;odo seleccionado</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Total Neto Adquisiciones</div>
                    <div class="kpi-valor" style="font-size: 24px;"><asp:Label ID="lblKpiNeto" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">Subtotal costo de insumos</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">IVA Cr&eacute;dito Fiscal (<asp:Label ID="lblKpiIvaPct" runat="server"></asp:Label>%)</div>
                    <div class="kpi-valor" style="font-size: 24px; color: #2980B9;"><asp:Label ID="lblKpiIva" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: #2980B9;">Impuesto recuperable</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Tasa de Recepci&oacute;n</div>
                    <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblKpiCumplimiento" runat="server" Text="0%"></asp:Label></div>
                    <div style="font-size: 11px; color: #27AE60;">&Oacute;rdenes recibidas s/ total</div>
                </div>
            </div>

            <!-- BARRA DE FILTROS AVANZADOS -->
            <div class="filter-card">
                <div class="filter-grid-5col">
                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <label class="label-dermo">Fecha Desde</label>
                        <asp:TextBox ID="txtFechaDesde" runat="server" TextMode="Date" CssClass="input-dermo"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <label class="label-dermo">Fecha Hasta</label>
                        <asp:TextBox ID="txtFechaHasta" runat="server" TextMode="Date" CssClass="input-dermo"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <label class="label-dermo">Laboratorio / Proveedor</label>
                        <asp:DropDownList ID="ddlLaboratorio" runat="server" CssClass="select-dermo"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <label class="label-dermo">Estado</label>
                        <asp:DropDownList ID="ddlEstado" runat="server" CssClass="select-dermo">
                            <asp:ListItem Value="" Text="Todos los Estados"></asp:ListItem>
                            <asp:ListItem Value="Borrador" Text="Borrador"></asp:ListItem>
                            <asp:ListItem Value="Emitida" Text="Emitida (Pendiente)"></asp:ListItem>
                            <asp:ListItem Value="Parcial" Text="Parcial"></asp:ListItem>
                            <asp:ListItem Value="Recibida" Text="Recibida"></asp:ListItem>
                            <asp:ListItem Value="Anulada" Text="Anulada"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div style="display: flex; gap: 8px;">
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn-dermo-primary" style="padding: 10px 18px;" OnClick="btnFiltrar_Click" />
                        <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar" CssClass="btn-dermo-secondary" style="padding: 10px 14px;" OnClick="btnLimpiar_Click" />
                    </div>
                </div>
            </div>

            <!-- HOJA FORMAL DEL REPORTE (EXPORTABLE A PDF) -->
            <div id="reporte-imprimible" class="printable-sheet">

                <!-- ENCABEZADO FORMAL DE REPORTE ACADEMICO / CORPORATIVO -->
                <div class="report-header-banner">
                    <div>
                        <div style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; color: var(--color-texto);">
                            NOMBRE - COSMETOLOG&Iacute;A PROFESIONAL
                        </div>
                        <div style="font-size: 11px; color: var(--color-texto-suave); letter-spacing: 1px; text-transform: uppercase; margin-top: 2px;">
                            Distribuidora de Dermocosm&eacute;tica y Cosmec&eacute;utica Profesional
                        </div>
                        <div style="font-size: 12px; margin-top: 8px; color: var(--color-acento); font-weight: 600;">
                            INFORME GERENCIAL: ESTADO DE &Oacute;RDENES DE COMPRA (RF-COM-11)
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 11px; color: var(--color-texto-suave); line-height: 1.6;">
                        <div><strong>Fecha Reporte:</strong> <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                        <div><strong>Auditor:</strong> <asp:Label ID="lblAuditor" runat="server"></asp:Label></div>
                        <div><strong>Sistema:</strong> ERP Dermo-Cosm&eacute;tica .NET</div>
                    </div>
                </div>

                <!-- GRILLA ANALITICA DE DATOS -->
                <div class="table-dermo-container" style="border: none; box-shadow: none;">
                    <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="False" CssClass="table-dermo-modern" EmptyDataText="No se registran &oacute;rdenes de compra para los par&aacute;metros seleccionados.">
                        <Columns>
                            <asp:TemplateField HeaderText="N&deg; OC">
                                <ItemTemplate>
                                    <strong style="color: var(--color-acento);"><%# Eval("NumeroOC") %></strong>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Proveedor">
                                <ItemTemplate>
                                    <div style="font-weight: 600;"><%# Eval("RazonSocial") %></div>
                                    <div style="font-size: 10px; color: var(--color-texto-suave);"><%# Eval("Rut") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Fecha" HeaderText="Emisi&oacute;n" DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="FechaEsperada" HeaderText="Entrega" DataFormatString="{0:dd/MM/yyyy}" />

                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='badge-oc badge-oc-<%# Eval("Estado").ToString().ToLower() %>'>
                                        <%# Eval("Estado") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="ItemsTotales" HeaderText="&Iacute;tems" />
                            <asp:BoundField DataField="Neto" HeaderText="Neto ($)" DataFormatString="{0:C0}" />
                            <asp:BoundField DataField="Iva" HeaderText="IVA ($)" DataFormatString="{0:C0}" />
                            <asp:TemplateField HeaderText="Total Compra ($)">
                                <ItemTemplate>
                                    <strong><%# string.Format("{0:C0}", Eval("Total")) %></strong>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- PIE DE REPORTE CON RESUMEN LIQUIDATORIO -->
                <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 30px; border-top: 1px solid var(--color-borde-suave); padding-top: 20px; flex-wrap: wrap;">
                    <div style="font-size: 11px; color: var(--color-texto-suave); max-width: 500px;">
                        <em>Documento anal&iacute;tico generado autom&aacute;ticamente por el m&oacute;dulo de Compras y Abastecimiento para control tributario y evaluaci&oacute;n presupuestaria. Taller de Ingenier&iacute;a de Software.</em>
                    </div>
                    <div style="text-align: right; font-size: 13px;">
                        <div>Total Inversi&oacute;n Per&iacute;odo: <strong style="font-size: 18px; color: var(--color-acento);"><asp:Label ID="lblResumenTotal" runat="server" Text="$0"></asp:Label></strong></div>
                    </div>
                </div>

                <!-- FIRMAS DE RESPONSABILIDAD DEL EQUIPO (DINÁMICAS DESDE CONFIGURACIONGLOBAL) -->
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-top: 50px; text-align: center; font-size: 11px;">
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaCompras" runat="server"></asp:Label></strong><br />
                        M&oacute;dulo de Compras y Abastecimiento
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaVentas" runat="server"></asp:Label></strong><br />
                        M&oacute;dulo de Ventas y Facturaci&oacute;n
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaInventario" runat="server"></asp:Label></strong><br />
                        M&oacute;dulo de Inventario y Kardex
                    </div>
                </div>

            </div>

        </div>

    </form>

    <script>
        function exportarPDF() {
            var elemento = document.getElementById('reporte-imprimible');
            var opt = {
                margin: [10, 10, 10, 10],
                filename: 'Reporte_Estado_Ordenes_Compra.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'letter', orientation: 'landscape' }
            };
            html2pdf().set(opt).from(elemento).save();
        }
    </script>
</body>
</html>
