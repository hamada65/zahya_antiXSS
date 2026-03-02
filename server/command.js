/**
 * zahya_antiXSS - FiveM server command
 * Run from FiveM server console: zahyaxss install | zahyaxss uninstall
 */

const fs = require('fs');
const path = require('path');

const CONFIG_ENTRY = "@zahya_antiXSS/config.lua";
const CHECKER_ENTRY = '@zahya_antiXSS/checker.lua';
const ZAHYA_RESOURCE = 'zahya_antiXSS';

const C = {
  red: '^1',
  green: '^2',
  yellow: '^3',
  blue: '^4',
  cyan: '^5',
  reset: '^7'
};

function findManifests(dir, manifests) {
  manifests = manifests || [];
  if (!fs.existsSync(dir)) return manifests;

  const entries = fs.readdirSync(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      findManifests(fullPath, manifests);
    } else if (entry.isFile() && (entry.name === 'fxmanifest.lua' || entry.name === '__resource.lua')) {
      manifests.push(fullPath);
    }
  }

  return manifests;
}

function isZahyaResource(manifestPath) {
  const dir = path.dirname(manifestPath);
  const dirName = path.basename(dir);
  return dirName === ZAHYA_RESOURCE;
}

function hasChecker(content) {
  const normalized = content.replace(/\s+/g, ' ');
  return (
    normalized.includes("'" + CHECKER_ENTRY + "'") ||
    normalized.includes('"' + CHECKER_ENTRY + '"') ||
    normalized.includes('@zahya_antiXSS/checker.lua')
  );
}

function addSharedScript(content) {
  return "shared_script '@zahya_antiXSS/config.lua'\nshared_script '@zahya_antiXSS/checker.lua'\n" + content;
}

function removeSharedScript(content) {
  let out = content;
  out = out.replace(/^\s*shared_script\s+['"]@zahya_antiXSS\/config\.lua['"]\s*\r?\n?/gm, '');
  out = out.replace(/^\s*shared_script\s+['"]@zahya_antiXSS\/checker\.lua['"]\s*\r?\n?/gm, '');
  return out !== content ? out : null;
}

function runInstall(serverRoot, uninstall) {
  const resourcesPath = path.join(serverRoot, 'resources');

  if (!fs.existsSync(resourcesPath)) {
    return { success: false, error: 'resources/ directory not found at ' + resourcesPath };
  }

  const manifests = findManifests(resourcesPath);
  let updated = 0;
  let skipped = 0;
  const updatedPaths = [];

  for (const manifestPath of manifests) {
    if (isZahyaResource(manifestPath)) {
      skipped++;
      continue;
    }

    let content;
    try {
      content = fs.readFileSync(manifestPath, 'utf8');
    } catch (err) {
      continue;
    }

    const newContent = uninstall ? removeSharedScript(content) : (hasChecker(content) ? null : addSharedScript(content));

    if (uninstall && !hasChecker(content)) {
      skipped++;
      continue;
    }

    if (newContent) {
      try {
        fs.writeFileSync(manifestPath, newContent, 'utf8');
        updatedPaths.push(path.relative(serverRoot, manifestPath));
        updated++;
      } catch (err) {}
    } else {
      skipped++;
    }
  }

  return { success: true, updated, skipped, updatedPaths };
}

function getServerRoot() {
  try {
    const resourcePath = GetResourcePath(GetCurrentResourceName());
    return path.resolve(resourcePath, '..', '..');
  } catch (e) {
    return path.resolve(__dirname, '..', '..');
  }
}

function doInstall(serverRoot, uninstall) {
  const result = runInstall(serverRoot, uninstall);
  if (!result.success) {
    console.log(C.red + '[zahya_antiXSS] Error: ' + result.error + C.reset);
    return;
  }
  const action = uninstall ? 'Uninstall' : 'Install';
  console.log(C.cyan + '[zahya_antiXSS] ' + action + ' - Scanning manifests...' + C.reset);
  result.updatedPaths.forEach(function (p) {
    console.log(C.green + '  Updated: ' + p + C.reset);
  });
  console.log(C.yellow + '[zahya_antiXSS] Done. ' + (uninstall ? 'Removed from' : 'Updated') + ' ' + result.updated + ' manifests, skipped ' + result.skipped + C.reset);
  if (result.updated > 0) {
    console.log(C.red + '[zahya_antiXSS] You must restart the server for changes to take effect.' + C.reset);
  }
}

RegisterCommand('zahyaxss', (source, args, rawCommand) => {
  if (source !== 0) return;
  const subcommand = (args[0] || '').toLowerCase();
  const uninstall = subcommand === 'uninstall';

  if (subcommand !== 'install' && subcommand !== 'uninstall') {
    console.log(C.yellow + 'Usage: zahyaxss install | zahyaxss uninstall' + C.reset);
    return;
  }

  doInstall(getServerRoot(), uninstall);
}, true);

setImmediate(function () {
  console.log(C.blue + '[zahya_antiXSS] Auto-installing shared script on all resources...' + C.reset);
  doInstall(getServerRoot(), false);
});
