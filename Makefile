.PHONY: package validate clean

package: validate
	@cd . && zip -r /tmp/code-enhancement-pipeline.plugin . \
		-x "*.DS_Store" -x ".git/*" -x "*.plugin" -x "Makefile" -x "LICENSE" -x ".gitignore"
	@cp /tmp/code-enhancement-pipeline.plugin ./code-enhancement-pipeline.plugin
	@echo "✓ Packaged: code-enhancement-pipeline.plugin"

validate:
	@python3 -c "\
	import json, pathlib, sys; \
	pj = json.loads(pathlib.Path('.claude-plugin/plugin.json').read_text()); \
	assert pj.get('name'), 'missing name'; \
	skills = list(pathlib.Path('skills').rglob('SKILL.md')); \
	agents = list(pathlib.Path('agents').glob('*.md')); \
	print(f'✓ {pj[\"name\"]} v{pj.get(\"version\",\"?\")}'); \
	print(f'  {len(skills)} skills, {len(agents)} agents'); \
	[print(f'  - skill: {s.parent.name}') for s in skills]; \
	[print(f'  - agent: {a.stem}') for a in agents]; \
	"

clean:
	rm -f *.plugin /tmp/code-enhancement-pipeline.plugin
