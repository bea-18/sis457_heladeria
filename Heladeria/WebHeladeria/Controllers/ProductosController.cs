using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebHeladeria.Models;

namespace WebHeladeria.Controllers
{
    public class ProductosController : Controller
    {
        private readonly FinalHeladeriaContext _context;

        public ProductosController(FinalHeladeriaContext context)
        {
            _context = context;
        }

        // GET: Productos
        public async Task<IActionResult> Index()
        {
            var finalHeladeriaContext = _context.Productos.Include(p => p.IdPresentacionNavigation).Include(p => p.IdProveedorNavigation).Include(p => p.IdSaborNavigation);
            var contexto = _context.Productos
            .Include(p => p.IdProveedorNavigation)
            .Include(p => p.IdSaborNavigation)
            .Include(p => p.IdPresentacionNavigation);
            return View(await finalHeladeriaContext.ToListAsync());
        }

        // GET: Productos/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var producto = await _context.Productos
                .Include(p => p.IdPresentacionNavigation)
                .Include(p => p.IdProveedorNavigation)
                .Include(p => p.IdSaborNavigation)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (producto == null)
            {
                return NotFound();
            }

            return View(producto);
        }

        // GET: Productos/Create
        public IActionResult Create()
        {
            ViewData["IdPresentacion"] = new SelectList(_context.Presentacions, "Id", "Descripcion");
            ViewData["IdProveedor"] = new SelectList(_context.Proveedors, "Id", "RazonSocial");
            ViewData["IdSabor"] = new SelectList(_context.Sabors, "Id", "Nombre");
            return View();
        }

        // POST: Productos/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Producto producto)
        {
            if (!string.IsNullOrWhiteSpace(producto.Nombre) &&
            producto.Precio > 0 &&
            producto.IdProveedor.HasValue &&
            producto.IdSabor.HasValue &&
            producto.IdPresentacion.HasValue)
            {
                // Puedes capturar otros valores automáticos si deseas
                producto.FechaRegistro = DateTime.Now;
                producto.UsuarioRegistro = User.Identity?.Name;
                producto.Estado = 1; // Activo por defecto

                _context.Add(producto);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["IdPresentacion"] = new SelectList(_context.Presentacions, "Id", "Id", producto.IdPresentacion);
            ViewData["IdProveedor"] = new SelectList(_context.Proveedors, "Id", "Id", producto.IdProveedor);
            ViewData["IdSabor"] = new SelectList(_context.Sabors, "Id", "Id", producto.IdSabor);
            return View(producto);
        }

        // GET: Productos/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var producto = await _context.Productos.FindAsync(id);
            if (producto == null)
            {
                return NotFound();
            }
            ViewData["IdPresentacion"] = new SelectList(_context.Presentacions, "Id", "Descripcion", producto.IdPresentacion);
            ViewData["IdProveedor"] = new SelectList(_context.Proveedors, "Id", "RazonSocial", producto.IdProveedor);
            ViewData["IdSabor"] = new SelectList(_context.Sabors, "Id", "Nombre", producto.IdSabor);
            return View(producto);
        }

        // POST: Productos/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        //public async Task<IActionResult> Edit(int id, [Bind("Id,Nombre,IdSabor,IdProveedor,IdPresentacion,Precio,UsuarioRegistro,FechaRegistro,Estado")] Producto producto)
        //{
        //    if (id != producto.Id)
        //    {
        //        return NotFound();
        //    }

        //    if (ModelState.IsValid)
        //    {
        //        try
        //        {
        //            _context.Update(producto);
        //            await _context.SaveChangesAsync();
        //        }
        //        catch (DbUpdateConcurrencyException)
        //        {
        //            if (!ProductoExists(producto.Id))
        //            {
        //                return NotFound();
        //            }
        //            else
        //            {
        //                throw;
        //            }
        //        }
        //        return RedirectToAction(nameof(Index));
        //    }
        //    ViewData["IdPresentacion"] = new SelectList(_context.Presentacions, "Id", "Descripcion", producto.IdPresentacion);
        //    ViewData["IdProveedor"] = new SelectList(_context.Proveedors, "Id", "RazonSocial", producto.IdProveedor);
        //    ViewData["IdSabor"] = new SelectList(_context.Sabors, "Id", "Nombre", producto.IdSabor);
        //    return View(producto);
        //}
        public async Task<IActionResult> Edit(int id, Producto producto)
        {
            if (id != producto.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(producto);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!_context.Productos.Any(e => e.Id == producto.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }

            // Recargar ViewBags si usas para selects
            ViewBag.IdSabor = new SelectList(_context.Sabors, "Id", "Nombre", producto.IdSabor);
            ViewBag.IdProveedor = new SelectList(_context.Proveedors, "Id", "RazonSocial", producto.IdProveedor);
            ViewBag.IdPresentacion = new SelectList(_context.Presentacions, "Id", "Descripcion", producto.IdPresentacion);

            return View(producto);
        }
        // GET: Productos/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var producto = await _context.Productos
                .Include(p => p.IdPresentacionNavigation)
                .Include(p => p.IdProveedorNavigation)
                .Include(p => p.IdSaborNavigation)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (producto == null)
            {
                return NotFound();
            }

            return View(producto);
        }

        // POST: Productos/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var producto = await _context.Productos.FindAsync(id);
            if (producto != null)
            {
                _context.Productos.Remove(producto);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool ProductoExists(int id)
        {
            return _context.Productos.Any(e => e.Id == id);
        }
    }
}
