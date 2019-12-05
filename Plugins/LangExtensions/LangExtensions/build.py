import os
import sys
import json
import shutil
import yaml

from pathlib import Path

languages = []
grammars = []

ignore_extensions = [
  'configuration-editing', 
  'extension-editing', 
  'search-result',
  'npm'
]

def load_package(path):
  path = path/'package.json'
  if path.exists:
    with path.open() as f:
      return json.load(f)      
  return None   

def main(path, outpath=Path(os.getcwd())):
  path = os.path.join(path, 'extensions')
  path = Path(path)

  extensions = [d for d in path.iterdir() 
                  if d.is_dir() and d.name not in ignore_extensions]
    
  for ext in extensions:
    pkg = load_package(ext)
    
    if not pkg or 'contributes' not in pkg:
      continue

    pkg = pkg['contributes']    
    
    if 'languages' not in pkg or 'grammars' not in pkg:
      continue

    ext_path = outpath / ext.relative_to(path)
    ext_path.mkdir(exist_ok=True)
    
    # Languages    
    for lang in pkg.get('languages', []):
      cfg_path = lang.get('configuration', None)
      if cfg_path:
        shutil.copy(ext/cfg_path, ext_path)
        lang['configuration'] = str(ext_path.relative_to(outpath)/Path(cfg_path).name)

      languages.append(lang)

    # Grammars
    for gram in pkg.get('grammars', []):
      gram_path = gram.get('path', None)
      if gram_path:
        shutil.copy(ext/gram_path, ext_path)
        gram['path'] = str(ext_path.relative_to(outpath)/Path(gram_path).name)

      grammars.append(gram)

  data = {
    'extensions': {
      'com.scade.nimble.CodeEditor': {
        'languages': languages,
        'grammars': grammars
      }
    }
  }

  outpath = outpath/'package.yml'
  with outpath.open(mode='w') as outfile:
    yaml.dump(data, outfile, default_flow_style=False, allow_unicode=True)


if __name__ == "__main__":
  main(sys.argv[1])