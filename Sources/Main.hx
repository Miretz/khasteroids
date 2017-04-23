package;

import kha.System;
import kha.Scheduler;
import kha.Assets;

class Main {
	public static function main() {
		System.init({title: "Khasteroids", width: 800, height: 600}, function () {
			Assets.loadEverything(function () {
				var project = new Project();
				System.notifyOnRender(project.render);
				Scheduler.addTimeTask(project.update, 0, 1 / 60);
			});
		});
	}
}
