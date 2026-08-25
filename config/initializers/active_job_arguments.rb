# Carrega ActiveJob::Arguments no boot, antes de qualquer thread de worker existir.
# docs/adr/0012-processo-de-jobs-no-host-windows.md
Rails.application.config.after_initialize do
  ActiveJob::Arguments
end
